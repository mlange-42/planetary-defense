use std::collections::BTreeSet;

use gdnative::prelude::*;
use gdnative::private::godot_object::Sealed;

use indexmap::map::Entry;
use pathfinding::prelude::dijkstra;

use crate::FxIndexMap;

#[allow(dead_code)]
#[derive(NativeClass, ToVariant)]
#[no_constructor]
#[inherit(Reference)]
pub struct Edge {
    #[property]
    from: i32,
    #[property]
    to: i32,
    #[property]
    net_type: i32,
    #[property]
    path_id: i32,
    #[property]
    capacity: u32,
    #[property]
    cost: u32,
}

#[methods]
impl Edge {
    #[export]
    fn _init(&mut self, _owner: &Reference) {}
}

#[allow(dead_code)]
impl Edge {
    fn new(from: usize, to: usize, net_type: usize, capacity: u32, cost: u32) -> Self {
        Self {
            from: from as i32,
            to: to as i32,
            net_type: net_type as i32,
            path_id: -1,
            capacity,
            cost,
        }
    }
    fn with_flow(
        from: usize,
        to: usize,
        net_type: usize,
        capacity: u32,
        cost: u32,
        path_id: i32,
    ) -> Self {
        Self {
            from: from as i32,
            to: to as i32,
            net_type: net_type as i32,
            cost,
            capacity,
            path_id,
        }
    }
}

#[derive(NativeClass, Default)]
#[inherit(Reference)]
pub struct FlowNetwork {
    network: Network,
}

impl Sealed for FlowNetwork {}

unsafe impl GodotObject for FlowNetwork {
    type RefKind = RefCounted;

    fn class_name() -> &'static str {
        "FlowNetwork"
    }
}

impl FlowNetwork {}

#[methods]
impl FlowNetwork {
    fn new(_owner: &Reference) -> Self {
        Self {
            network: Default::default(),
        }
    }

    #[export]
    fn _init(&mut self, _owner: &Reference) {}

    #[export]
    pub fn reset_flow(&mut self, _owner: &Reference) {
        self.network.reset_flow();
    }

    #[export]
    pub fn set_facility(&mut self, _owner: &Reference, v: usize, is_facility: bool) {
        self.network.set_facility(v, is_facility);
    }

    #[export]
    pub fn is_road(&self, _owner: &Reference, v: usize) -> bool {
        self.network.is_road(v)
    }

    #[export]
    pub fn points_connected(&self, _owner: &Reference, v1: usize, v2: usize) -> bool {
        self.network.points_connected(v1, v2)
    }

    #[export]
    pub fn connect_points(
        &mut self,
        _owner: &Reference,
        v1: usize,
        v2: usize,
        net_type: usize,
        capacity: u32,
        cost: u32,
    ) {
        self.network
            .connect_points(v1, v2, net_type, capacity, cost);
    }

    #[export]
    #[allow(clippy::too_many_arguments)]
    pub fn connect_points_directional(
        &mut self,
        _owner: &Reference,
        v1: usize,
        v2: usize,
        net_type: usize,
        capacity: u32,
        cost: u32,
        path_id: i32,
    ) {
        self.network
            .connect_points_directional(v1, v2, net_type, capacity, cost, path_id);
    }

    #[export]
    pub fn disconnect_points(&mut self, _owner: &Reference, v1: usize, v2: usize) {
        self.network.disconnect_points(v1, v2);
    }

    #[export]
    pub fn get_node_count(&self, _owner: &Reference) -> usize {
        self.network.neighbors.len()
    }

    #[export]
    pub fn get_node_at(&self, _owner: &Reference, index: usize) -> Option<(&usize, &Vec<usize>)> {
        self.network.neighbors.get_index(index)
    }

    #[export]
    pub fn get_node(&self, _owner: &Reference, key: usize) -> Option<&Vec<usize>> {
        self.network.neighbors.get(&key)
    }

    #[export]
    pub fn get_edge_count(&self, _owner: &Reference) -> usize {
        self.network.edges.len()
    }

    #[export]
    pub fn get_edge_at(&self, _owner: &Reference, index: usize) -> Option<&Edge> {
        self.network.edges.get_index(index).map(|(_k, v)| v)
    }

    #[export]
    pub fn get_edge(&self, _owner: &Reference, key: (usize, usize)) -> Option<&Edge> {
        self.network.edges.get(&key)
    }

    #[export]
    pub fn get_collapsed_edges(&mut self, _owner: &Reference) -> Vec<(Vec<usize>, u32, u32)> {
        self.network.get_collapsed_edges()
    }

    #[export]
    fn get_id_path(&self, _owner: &Reference, from: usize, to: usize) -> Vec<usize> {
        self.network
            .find_path(from, to)
            .map(|(v, _c)| v)
            .unwrap_or_else(Vec::new)
    }

    pub fn network(&self) -> &Network {
        &self.network
    }
}

#[derive(Default)]
pub struct Network {
    neighbors: FxIndexMap<usize, Vec<usize>>,
    edges: FxIndexMap<(usize, usize), Edge>,
    facilities: BTreeSet<usize>,
}

#[allow(dead_code)]
impl Network {
    pub fn reset_flow(&mut self) {
        for (_, edge) in self.edges.iter_mut() {
            edge.path_id = -1;
        }
    }

    pub fn set_facility(&mut self, v: usize, is_facility: bool) {
        assert_ne!(
            self.facilities.contains(&v),
            is_facility,
            "There is {} facility at node {}",
            if is_facility { "already a" } else { "no" },
            v
        );

        if is_facility {
            self.facilities.insert(v);
        } else {
            self.facilities.remove(&v);
        }
    }

    pub fn is_road(&self, v: usize) -> bool {
        self.neighbors.contains_key(&v)
    }

    pub fn points_connected(&self, v1: usize, v2: usize) -> bool {
        self.edges.contains_key(&(v1, v2))
    }

    pub fn connect_points(
        &mut self,
        v1: usize,
        v2: usize,
        net_type: usize,
        capacity: u32,
        cost: u32,
    ) {
        self._connect(v1, v2, net_type, capacity, cost, -1);
        self._connect(v2, v1, net_type, capacity, cost, -1);
    }

    pub fn connect_points_directional(
        &mut self,
        v1: usize,
        v2: usize,
        net_type: usize,
        capacity: u32,
        cost: u32,
        path_id: i32,
    ) {
        self._connect(v1, v2, net_type, capacity, cost, path_id);
    }

    pub fn disconnect_points(&mut self, v1: usize, v2: usize) {
        self._disconnect(v1, v2);
        self._disconnect(v2, v1);
    }

    pub fn find_path(&self, from: usize, to: usize) -> Option<(Vec<usize>, u32)> {
        dijkstra(
            &from,
            |id| self.neighbors[id].iter().map(|node| (*node, 1)),
            |id| id == &to,
        )
    }

    pub fn get_collapsed_edges(&mut self) -> Vec<(Vec<usize>, u32, u32)> {
        let mut edge_list = vec![];

        for (key, n) in &self.neighbors {
            if n.len() == 2 && !self.facilities.contains(key) {
                continue;
            }

            for i in 0..n.len() {
                let trace = self.trace_edge(*key, i);
                if let Some(trace) = trace {
                    let idx = edge_list.len();
                    for pp in trace.0.windows(2) {
                        self.edges[&(pp[0], pp[1])].path_id = idx as i32;
                    }
                    edge_list.push(trace);
                }
            }
        }

        edge_list
    }

    fn trace_edge(&self, node: usize, neighbor: usize) -> Option<(Vec<usize>, u32, u32)> {
        let mut result = vec![node];

        let first = node;
        let mut previous = node;
        let mut current = self.neighbors[&node][neighbor];
        let mut capacity = u32::MAX;
        let mut cost = 0;

        loop {
            if current == first {
                return None;
            }

            result.push(current);
            let edge = &self.edges[&(previous, current)];
            cost += edge.cost;
            if edge.capacity < capacity {
                capacity = edge.capacity;
            }

            let n = &self.neighbors[&current];
            if n.len() != 2 || self.facilities.contains(&current) {
                return Some((result, capacity, cost));
            }

            let n0 = n[0];
            let old = previous;
            previous = current;
            current = if n0 != old { n0 } else { n[1] };
        }
    }

    fn _connect(
        &mut self,
        v1: usize,
        v2: usize,
        net_type: usize,
        capacity: u32,
        cost: u32,
        path_id: i32,
    ) {
        match self.neighbors.entry(v1) {
            Entry::Vacant(e) => {
                e.insert(vec![v2]);
            }
            Entry::Occupied(mut e) => {
                assert!(
                    !e.get().contains(&v2),
                    "Points {} and {} are already connected",
                    v1,
                    v2
                );
                e.get_mut().push(v2);
            }
        }
        self.edges.insert(
            (v1, v2),
            Edge::with_flow(v1, v2, net_type, capacity, cost, path_id),
        );
    }

    fn _disconnect(&mut self, v1: usize, v2: usize) {
        let mut is_empty = false;
        match self.neighbors.entry(v1) {
            Entry::Vacant(_) => panic!("Points {} and {} are not connected", v1, v2,),
            Entry::Occupied(mut e) => {
                let idx = e.get().iter().position(|v| *v == v2);
                assert!(idx.is_some(), "Points {} and {} are not connected", v1, v2);
                e.get_mut().remove(idx.unwrap());
                if e.get().is_empty() {
                    is_empty = true;
                }
            }
        }
        if is_empty {
            assert!(
                self.neighbors.remove(&v1).is_some(),
                "Points {} and {} are not connected",
                v1,
                v2
            );
        }

        assert!(
            self.edges.remove(&(v1, v2)).is_some(),
            "Points {} and {} have no edge to remove",
            v1,
            v2
        );
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_network() {
        let tp = 0;
        let cap = 10;
        let cost = 1;

        let mut net = Network::default();

        net.connect_points(0, 1, tp, cap, cost);
        assert_eq!(net.edges.len(), 2);
        net.disconnect_points(0, 1);
        assert_eq!(net.edges.len(), 0);
        net.connect_points(0, 1, tp, cap, cost);

        net.connect_points(1, 2, tp, cap, cost);
        net.connect_points(2, 3, tp, cap, cost);

        net.connect_points(3, 4, tp, cap, cost);
        net.connect_points(4, 5, tp, cap, cost);

        net.connect_points(3, 6, tp, cap, cost);
        net.connect_points(6, 7, tp, cap, cost);

        net.set_facility(1, true);
        assert_eq!(net.facilities.len(), 1);
        net.set_facility(1, false);
        assert_eq!(net.facilities.len(), 0);
        net.set_facility(1, true);

        let edges = net.get_collapsed_edges();

        println!("{:?}", edges);

        assert_eq!(edges.len(), 8);
        assert_eq!(edges[0].1, cap);

        assert_eq!(net.find_path(0, 7), Some((vec![0, 1, 2, 3, 6, 7], 5)));
        assert_eq!(net.find_path(0, 5), Some((vec![0, 1, 2, 3, 4, 5], 5)));
        assert_eq!(net.find_path(5, 7), Some((vec![5, 4, 3, 6, 7], 4)));
    }
}
