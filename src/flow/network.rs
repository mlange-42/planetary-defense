use std::collections::btree_map::Entry;
use std::collections::{BTreeMap, BTreeSet};

#[allow(dead_code)]
struct Edge {
    from: usize,
    to: usize,
    flow: u32,
    capacity: u32,
}

#[allow(dead_code)]
impl Edge {
    fn new(from: usize, to: usize, capacity: u32) -> Self {
        Self {
            from,
            to,
            flow: 0,
            capacity,
        }
    }
}

#[allow(dead_code)]
#[derive(Default)]
pub struct FlowNetwork {
    neighbors: BTreeMap<usize, Vec<usize>>,
    edges: BTreeMap<(usize, usize), Edge>,
    facilities: BTreeSet<usize>,
}

#[allow(dead_code)]
impl FlowNetwork {
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

    pub fn connect_points(&mut self, v1: usize, v2: usize, capacity: u32) {
        self._connect(v1, v2, capacity);
        self._connect(v2, v1, capacity);
    }

    pub fn disconnect_points(&mut self, v1: usize, v2: usize) {
        self._disconnect(v1, v2);
        self._disconnect(v2, v1);
    }

    fn get_edges(&self) -> Vec<(Vec<usize>, u32)> {
        let mut edge_list = vec![];

        for (key, n) in &self.neighbors {
            if n.len() == 2 && !self.facilities.contains(key) {
                continue;
            }

            for i in 0..n.len() {
                let trace = self.trace_edge(*key, i);
                if let Some(trace) = trace {
                    edge_list.push(trace);
                }
            }
        }

        edge_list
    }

    fn trace_edge(&self, node: usize, neighbor: usize) -> Option<(Vec<usize>, u32)> {
        let mut result = vec![node];

        let first = node;
        let mut previous = node;
        let mut current = self.neighbors[&node][neighbor];
        let mut capacity = u32::MAX;

        loop {
            if current == first {
                return None;
            }

            result.push(current);
            let edge = &self.edges[&(previous, current)];
            if edge.capacity < capacity {
                capacity = edge.capacity;
            }

            let n = &self.neighbors[&current];
            if n.len() != 2 || self.facilities.contains(&current) {
                return Some((result, capacity));
            }

            let n0 = n[0];
            let old = previous;
            previous = current;
            current = if n0 != old { n0 } else { n[1] };
        }
    }

    fn _connect(&mut self, v1: usize, v2: usize, capacity: u32) {
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
        self.edges.insert((v1, v2), Edge::new(v1, v2, capacity));
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
        let mut net = FlowNetwork::default();

        net.connect_points(0, 1, 10);
        assert_eq!(net.edges.len(), 2);
        net.disconnect_points(0, 1);
        assert_eq!(net.edges.len(), 0);
        net.connect_points(0, 1, 10);

        net.connect_points(1, 2, 10);
        net.connect_points(2, 3, 10);

        net.connect_points(3, 4, 10);
        net.connect_points(4, 5, 10);

        net.connect_points(3, 6, 10);
        net.connect_points(6, 7, 10);

        net.set_facility(1, true);
        assert_eq!(net.facilities.len(), 1);
        net.set_facility(1, false);
        assert_eq!(net.facilities.len(), 0);
        net.set_facility(1, true);

        let edges = net.get_edges();

        assert_eq!(edges.len(), 8);
        assert_eq!(edges[0].1, 10);
    }
}
