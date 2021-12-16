use std::collections::HashMap;

use pathfinding::directed::dijkstra::dijkstra;

#[allow(dead_code)]
struct Neighbor {
    node: usize,
    capacity: u32,
    cost: u32,
}

#[allow(dead_code)]
pub struct Graph {
    num_commodities: usize,
    successors: HashMap<usize, Vec<Neighbor>>,
    predecessors: HashMap<usize, Vec<Neighbor>>,
    sources: Vec<Option<usize>>,
    sinks: Vec<Option<usize>>,
}

#[allow(dead_code)]
impl Graph {
    fn new(num_commodities: usize) -> Self {
        Self {
            num_commodities,
            successors: Default::default(),
            predecessors: Default::default(),
            sources: vec![None; num_commodities],
            sinks: vec![None; num_commodities],
        }
    }

    fn add_edge(&mut self, from: usize, to: usize, capacity: u32, cost: u32) {
        self.successors.entry(from).or_default().push(Neighbor {
            node: to,
            capacity,
            cost,
        });
        self.predecessors.entry(to).or_default().push(Neighbor {
            node: from,
            capacity,
            cost,
        });
    }

    fn set_source(&mut self, commodity: usize, node: usize) {
        assert!(
            self.sources[commodity].is_none(),
            "Source node for commodity {} already set",
            commodity
        );
        self.sources[commodity] = Some(node);
    }

    fn set_sink(&mut self, commodity: usize, node: usize) {
        assert!(
            self.sinks[commodity].is_none(),
            "Sink node for commodity {} already set",
            commodity
        );
        self.sinks[commodity] = Some(node);
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
            assert!(s.is_some(), "No source set for commodity {}", i);
        }
        for (i, s) in self.graph.sinks.iter().enumerate() {
            assert!(s.is_some(), "No sink set for commodity {}", i);
        }
    }

    fn solve(&self) {
        self.check();

        let g = &self.graph;

        let total_source = sum_amount(&g.sources, &g.successors);
        let total_sink = sum_amount(&g.sinks, &g.predecessors);

        let mut remaining: Vec<_> = total_source
            .iter()
            .zip(&total_sink)
            .map(|(s, t)| s.min(&t))
            .collect();

        println!("{:?}", total_source);
        println!("{:?}", total_sink);
        println!("{:?}", remaining);

        let comm = 0;
        let result = find_path(g, comm);

        println!("{:?}", result);
    }
}

fn find_path(graph: &Graph, commodity: usize) -> Option<(Vec<usize>, u32)> {
    let start = &graph.sources[commodity].unwrap();

    dijkstra::<usize, u32, _, Vec<_>, _>(
        start,
        |id| {
            let s = graph.successors[&id]
                .iter()
                .map(|succ| (succ.node, succ.cost))
                .collect();
            s
        },
        |id| *id == graph.sinks[commodity].unwrap(),
    )
}

fn sum_amount(
    node_indices: &Vec<Option<usize>>,
    neighbors: &HashMap<usize, Vec<Neighbor>>,
) -> Vec<u32> {
    node_indices
        .iter()
        .map(|idx| {
            neighbors[&idx.unwrap()]
                .iter()
                .map(|succ| succ.capacity)
                .sum::<u32>()
        })
        .collect::<Vec<_>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_network() {
        let mut graph = Graph::new(2);

        graph.add_edge(0, 2, 10, 0);
        graph.add_edge(1, 3, 10, 0);
        graph.set_source(0, 0);
        graph.set_source(1, 1);

        graph.add_edge(2, 4, 10, 1);
        graph.add_edge(3, 5, 10, 1);
        graph.add_edge(2, 5, 10, 1);
        graph.add_edge(3, 4, 10, 1);

        graph.add_edge(4, 6, 10, 0);
        graph.add_edge(5, 7, 10, 0);
        graph.set_sink(0, 6);
        graph.set_sink(1, 7);

        let solver = MultiComPath::new(graph);

        solver.solve();
    }
}
