use gdnative::prelude::*;
use mcmf::{Capacity, Cost, GraphBuilder, Vertex};

#[derive(NativeClass)]
#[inherit(Node)]
pub struct NetworkSimplex {
    builder: GraphBuilder<usize>,
}

#[methods]
impl NetworkSimplex {
    fn new(_owner: &Node) -> Self {
        godot_print!("Creating NetworkSimplex");
        Self {
            builder: GraphBuilder::new(),
        }
    }

    #[export]
    fn _ready(&mut self, _owner: &Node) {}

    #[export]
    fn reset(&mut self, _owner: &Node) {
        self.builder = GraphBuilder::new();
    }

    #[export]
    fn add_edge(&mut self, _owner: &Node, from: usize, to: usize, capacity: i32, cost: i32) {
        self.builder
            .add_edge(from, to, Capacity(capacity), Cost(cost));
    }

    #[export]
    fn add_source_edge(&mut self, _owner: &Node, to: usize, capacity: i32, cost: i32) {
        self.builder
            .add_edge(Vertex::Source, to, Capacity(capacity), Cost(cost));
    }

    #[export]
    fn add_sink_edge(&mut self, _owner: &Node, from: usize, capacity: i32, cost: i32) {
        self.builder
            .add_edge(from, Vertex::Sink, Capacity(capacity), Cost(cost));
    }

    #[export]
    fn solve(&self, _owner: &Node) -> Vec<Vec<(isize, isize, u32, i32)>> {
        let (_cost, paths) = self.builder.mcmf();

        let p = paths
            .iter()
            .map(|path| {
                path.flows
                    .iter()
                    .map(|flow| {
                        (
                            vertex_to_id(&flow.a),
                            vertex_to_id(&flow.b),
                            flow.amount,
                            flow.cost,
                        )
                    })
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();
        p
    }
}

fn vertex_to_id(vertex: &Vertex<usize>) -> isize {
    match vertex {
        Vertex::Source => -1,
        Vertex::Sink => -2,
        Vertex::Node(id) => *id as isize,
    }
}
