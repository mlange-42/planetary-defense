use rand::prelude::*;
use std::collections::BTreeMap;
use std::fmt::Debug;
use std::iter;

use pathfinding::directed::dijkstra::dijkstra;

#[derive(Copy, Clone, Hash, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum Vertex<T: Clone + Ord, U: Clone + Ord> {
    Source(U),
    Sink(U),
    Node(T),
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Cost(pub i32);

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Capacity(pub i32);

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct Node(usize);

#[derive(Debug)]
struct Edge {
    pub a: Node,
    pub b: Node,
    pub data: EdgeData,
}

#[derive(Clone, Debug)]
struct NodeData {
    supply: Vec<i32>,
}

impl NodeData {
    fn new(commodities: usize) -> Self {
        Self {
            supply: vec![0; commodities],
        }
    }
}

#[derive(Clone, Copy, Debug)]
struct EdgeData {
    cost: i32,
    capacity: i32,
    flow: i32,
}

impl EdgeData {
    pub fn new(cost: Cost, capacity: Capacity) -> Self {
        let cost = cost.0 as i32;
        let capacity = capacity.0 as i32;
        assert!(capacity >= 0);
        EdgeData {
            cost,
            capacity,
            flow: Default::default(),
        }
    }
}
#[derive(Clone, Debug)]
pub struct Flow<T: Clone + Ord, U: Clone + Ord> {
    pub a: Vertex<T, U>,
    pub b: Vertex<T, U>,
    pub amount: u32,
    pub cost: i32,
}

struct Graph {
    commodities: usize,
    nodes: Vec<NodeData>,
    edges: Vec<Edge>,
    out_edges: Vec<Vec<usize>>,
}

impl Graph {
    pub fn add_edge(&mut self, a: Node, b: Node, data: EdgeData) -> &mut Self {
        assert!(a.0 < self.nodes.len());
        assert!(b.0 < self.nodes.len());
        self.edges.push(Edge { a, b, data });
        self.out_edges[a.0].push(self.edges.len() - 1);
        self
    }
    pub fn extract(self) -> (Vec<NodeData>, Vec<Edge>) {
        (self.nodes, self.edges)
    }
}

impl Graph {
    pub fn delta_supply(&mut self, node: Node, commodity: usize, amount: i32) {
        self.nodes[node.0].supply[commodity] += amount;
    }
    pub fn new_default(num_vertices: usize, commodities: usize) -> Self {
        let nodes = vec![NodeData::new(commodities); num_vertices];
        let out_edges = vec![vec![]; num_vertices];
        Graph {
            commodities,
            nodes,
            edges: Vec::new(),
            out_edges,
        }
    }

    fn solve(&mut self) {
        let mut has_path = vec![true; self.commodities];
        let mut total_transported = vec![0; self.commodities];

        while has_path.iter().any(|p| *p) {
            let comm = thread_rng().gen_range(0..self.commodities);
            if !has_path[comm] {
                continue;
            }
            let result = self.find_path(comm);
            if let Some((path, _cost)) = result {
                self.apply_path(&path, comm, 1);
                total_transported[comm] += 1;
                has_path[comm] = true;
                // println!("{:?}", path);
            } else {
                has_path[comm] = false;
            }
        }
    }

    fn apply_path(&mut self, path: &Vec<usize>, commodity: usize, amount: u32) {
        for i in 0..(path.len() - 1) {
            let n1 = path[i];
            let n2 = path[i + 1];
            let edge_idx = self.out_edges[n1]
                .iter()
                .find(|id| self.edges[**id].b.0 == n2)
                .unwrap();

            self.edges[*edge_idx].data.flow += amount as i32;
        }
        self.nodes[path[0]].supply[commodity] -= amount as i32;
        self.nodes[path[path.len() - 1]].supply[commodity] += amount as i32;
    }

    fn find_path(&self, commodity: usize) -> Option<(Vec<usize>, u32)> {
        let sources = self.nodes.iter().enumerate().filter_map(|(i, n)| {
            if n.supply[commodity] > 0 {
                Some(i)
            } else {
                None
            }
        });

        if let Some(start) = sources.choose(&mut rand::thread_rng()) {
            dijkstra::<usize, u32, _, Vec<_>, _>(
                &start,
                |id| self.get_successor(*id),
                |id| self.nodes[*id].supply[commodity] < 0,
            )
        } else {
            None
        }
    }

    fn get_successor(&self, id: usize) -> Vec<(usize, u32)> {
        let s = self.out_edges[id]
            .iter()
            .filter_map(|edge_id| {
                let edge = &self.edges[*edge_id];
                let remaining = edge.data.capacity - edge.data.flow;
                if remaining <= 0 {
                    None
                } else {
                    let rel_remaining = remaining as f32 / edge.data.capacity as f32;
                    Some((
                        edge.b.0,
                        (edge.data.cost as f32 / rel_remaining).round() as u32,
                    ))
                }
            })
            .collect();
        s
    }
}

#[allow(dead_code)]
pub struct GraphBuilder<T: Clone + Ord, U: Clone + Ord> {
    pub edge_list: Vec<(Vertex<T, U>, Vertex<T, U>, Capacity, Cost)>,
}

#[allow(dead_code)]
impl<T: Clone + Ord + Debug, U: Clone + Ord + Debug> GraphBuilder<T, U> {
    fn new() -> Self {
        Self {
            edge_list: Vec::new(),
        }
    }

    pub fn add_edge<A: Into<Vertex<T, U>>, B: Into<Vertex<T, U>>>(
        &mut self,
        a: A,
        b: B,
        capacity: Capacity,
        cost: Cost,
    ) -> &mut Self {
        if capacity.0 < 0 {
            panic!("capacity cannot be negative (capacity was {})", capacity.0)
        }
        let a = a.into();
        let b = b.into();
        assert_ne!(a, b);
        assert!(!matches!(a, Vertex::Sink(_)));
        assert!(!matches!(b, Vertex::Source(_)));
        self.edge_list.push((a, b, capacity, cost));
        self
    }

    fn solve(&self) -> Vec<Flow<T, U>> {
        let mut next_id = 0;
        let mut next_comm_id = 0_usize;
        let mut index_mapper = BTreeMap::new();
        let mut node_mapper = BTreeMap::new();
        let mut commodity_mapper = BTreeMap::new();
        for vertex in self
            .edge_list
            .iter()
            .flat_map(move |&(ref a, ref b, _, _)| iter::once(a).chain(iter::once(b)))
        {
            if !index_mapper.contains_key(&vertex) {
                index_mapper.insert(vertex, next_id);
                node_mapper.insert(next_id, vertex);
                next_id += 1;
            }
            if let Vertex::Source(comm) = vertex {
                if !commodity_mapper.contains_key(comm) {
                    commodity_mapper.insert(comm, next_comm_id);
                    next_comm_id += 1;
                }
            }
            if let Vertex::Sink(comm) = vertex {
                if !commodity_mapper.contains_key(comm) {
                    commodity_mapper.insert(comm, next_comm_id);
                    next_comm_id += 1;
                }
            }
        }

        let num_vertices = next_id;
        let mut g = Graph::new_default(num_vertices, commodity_mapper.len());
        for &(ref a, ref b, cap, cost) in &self.edge_list {
            let node_a = Node(*index_mapper.get(&a).unwrap());
            let node_b = Node(*index_mapper.get(&b).unwrap());
            if let Vertex::Source(comm) = a {
                g.delta_supply(
                    Node(*index_mapper.get(&a).unwrap()),
                    *commodity_mapper.get(comm).unwrap(),
                    cap.0,
                );
            }
            if let Vertex::Sink(comm) = b {
                g.delta_supply(
                    Node(*index_mapper.get(&b).unwrap()),
                    *commodity_mapper.get(comm).unwrap(),
                    -cap.0,
                );
            }
            g.add_edge(node_a, node_b, EdgeData::new(cost, cap));
        }

        g.solve();

        let (_, edges) = g.extract();
        let flows: Vec<_> = edges
            .iter()
            .map(|e| Flow {
                a: node_mapper[&e.a.0].clone(),
                b: node_mapper[&e.b.0].clone(),
                amount: e.data.flow as u32,
                cost: e.data.cost,
            })
            .collect();

        flows
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_network() {
        let mut builder = GraphBuilder::new();

        builder.add_edge(
            Vertex::Source("Res"),
            Vertex::Node("A"),
            Capacity(10),
            Cost(0),
        );
        builder.add_edge(
            Vertex::Source("Prod"),
            Vertex::Node("B"),
            Capacity(10),
            Cost(0),
        );

        builder.add_edge(
            Vertex::Node("A"),
            Vertex::Node("C"),
            Capacity(10),
            Cost(100),
        );
        builder.add_edge(
            Vertex::Node("B"),
            Vertex::Node("D"),
            Capacity(10),
            Cost(100),
        );
        builder.add_edge(
            Vertex::Node("A"),
            Vertex::Node("D"),
            Capacity(10),
            Cost(100),
        );
        builder.add_edge(
            Vertex::Node("B"),
            Vertex::Node("C"),
            Capacity(10),
            Cost(100),
        );

        builder.add_edge(
            Vertex::Node("C"),
            Vertex::Sink("Res"),
            Capacity(10),
            Cost(0),
        );
        builder.add_edge(
            Vertex::Node("D"),
            Vertex::Sink("Prod"),
            Capacity(10),
            Cost(0),
        );

        let flows = builder.solve();

        println!("{:?}", flows);
    }
}
