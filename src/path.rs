use std::collections::{HashMap, HashSet};

use pathfinding::directed::dijkstra::dijkstra;
use rand::prelude::*;

#[allow(dead_code)]
struct Neighbor {
    here: usize,
    there: usize,
    capacity: u32,
    cost: u32,
    flow: u32,
}

#[allow(dead_code)]
pub struct Graph {
    num_commodities: usize,
    successors: HashMap<usize, Vec<Neighbor>>,
    predecessors: HashMap<usize, Vec<Neighbor>>,
    sources: Vec<HashSet<usize>>,
    sinks: Vec<HashSet<usize>>,
}

#[allow(dead_code)]
impl Graph {
    fn new(num_commodities: usize) -> Self {
        Self {
            num_commodities,
            successors: Default::default(),
            predecessors: Default::default(),
            sources: vec![Default::default(); num_commodities],
            sinks: vec![Default::default(); num_commodities],
        }
    }

    fn add_edge(&mut self, from: usize, to: usize, capacity: u32, cost: u32) {
        self.successors.entry(from).or_default().push(Neighbor {
            here: from,
            there: to,
            capacity,
            cost,
            flow: 0,
        });
        self.predecessors.entry(to).or_default().push(Neighbor {
            here: to,
            there: from,
            capacity,
            cost,
            flow: 0,
        });
    }

    fn set_source(&mut self, commodity: usize, node: usize) {
        assert!(
            self.successors.get(&node).map_or(true, |s| s.len() == 1),
            "Source nodes may not have more than one successor!"
        );
        self.sources[commodity].insert(node);
    }

    fn set_sink(&mut self, commodity: usize, node: usize) {
        assert!(
            self.predecessors.get(&node).map_or(true, |s| s.len() == 1),
            "Source nodes may not have more than one predecessors!"
        );
        self.sinks[commodity].insert(node);
    }
}

#[allow(dead_code)]
pub struct MultiComPath {
    graph: Graph,
}

#[allow(dead_code)]
impl MultiComPath {
    fn new(graph: Graph) -> Self {
        Self { graph }
    }

    fn check(&self) {
        for (i, s) in self.graph.sources.iter().enumerate() {
            assert!(!s.is_empty(), "No source set for commodity {}", i);
        }
        for (i, s) in self.graph.sinks.iter().enumerate() {
            assert!(!s.is_empty(), "No sink set for commodity {}", i);
        }
    }

    fn solve(&mut self) {
        self.check();

        let g = &mut self.graph;

        let mut has_path = vec![true; g.num_commodities];
        let mut total_transported = vec![0; g.num_commodities];

        while has_path.iter().any(|p| *p) {
            let comm = thread_rng().gen_range(0..g.num_commodities);
            if !has_path[comm] {
                continue;
            }
            let result = find_path(g, comm);
            if let Some((path, _cost)) = result {
                apply_path(g, &path, 1);
                total_transported[comm] += 1;
                has_path[comm] = true;
                println!("{:?}", path);
            } else {
                has_path[comm] = false;
            }
        }

        println!("Total transported: {:?}", total_transported);
    }
}

fn apply_path(graph: &mut Graph, path: &Vec<usize>, amount: u32) {
    for i in 0..(path.len() - 1) {
        let n1 = path[i];
        let n2 = path[i + 1];
        let edge_idx = graph.successors[&n1]
            .iter()
            .enumerate()
            .find_map(|(i, s)| if s.there == n2 { Some(i) } else { None })
            .unwrap();

        graph.successors.get_mut(&n1).unwrap()[edge_idx].flow += amount;
    }
}

fn find_path(graph: &Graph, commodity: usize) -> Option<(Vec<usize>, u32)> {
    let start = &graph.sources[commodity]
        .iter()
        .choose(&mut rand::thread_rng())
        .unwrap();

    dijkstra::<usize, u32, _, Vec<_>, _>(
        start,
        |id| get_successor(graph, *id),
        |id| graph.sinks[commodity].contains(id),
    )
}

fn get_successor(graph: &Graph, id: usize) -> Vec<(usize, u32)> {
    if !graph.successors.contains_key(&id) {
        return vec![];
    }
    let s = graph.successors[&id]
        .iter()
        .filter_map(|succ| {
            let remaining = succ.capacity - succ.flow;
            if remaining <= 0 {
                None
            } else {
                let rel_remaining = remaining as f32 / succ.capacity as f32;
                Some((
                    succ.there,
                    (succ.cost as f32 / rel_remaining).round() as u32,
                ))
            }
        })
        .collect();
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_network() {
        let mut graph = Graph::new(2);

        graph.add_edge(2, 4, 20, 100);
        graph.add_edge(3, 5, 20, 100);
        graph.add_edge(2, 5, 20, 100);
        graph.add_edge(3, 4, 20, 100);

        graph.add_edge(0, 2, 20, 0);
        graph.set_source(0, 0);
        graph.add_edge(1, 3, 10, 0);
        graph.set_source(1, 1);

        graph.add_edge(4, 6, 20, 0);
        graph.set_sink(0, 6);
        graph.add_edge(5, 7, 10, 0);
        graph.set_sink(1, 7);

        let mut solver = MultiComPath::new(graph);

        solver.solve();
    }
}
