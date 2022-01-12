use rand::prelude::*;
use std::collections::btree_map::Entry as BEntry;
use std::collections::hash_map::Entry;
use std::collections::{BTreeMap, HashMap};
use std::fmt::Debug;
use std::hash::Hash;
use std::iter;

use pathfinding::directed::dijkstra::dijkstra;

use crate::flow::network::FlowNetwork;
use gdnative::api::Reference;
use gdnative::core_types::Dictionary;
use gdnative::prelude::*;

type GodotFlows = Vec<(isize, isize, u32, u32, u32)>;

#[derive(Eq, PartialEq, ToVariant)]
pub struct NodePair(isize, isize);
impl ToVariantEq for NodePair {}

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct MultiCommodityFlow {
    builder: GraphBuilder<usize, String>,
}

#[methods]
impl MultiCommodityFlow {
    fn new(_owner: &Reference) -> Self {
        Self {
            builder: GraphBuilder::new(),
        }
    }

    #[export]
    fn _init(&mut self, _owner: &Reference) {}

    #[export]
    fn reset(&mut self, _owner: &Reference) {
        self.builder = GraphBuilder::new();
    }

    #[export]
    fn add_network(&mut self, _owner: &Reference, net: Ref<FlowNetwork>) {
        for (path, cap) in unsafe { net.assume_unique() }.network().get_edges() {
            self.builder.add_edge(
                *path.first().unwrap(),
                *path.last().unwrap(),
                Capacity(cap as i32),
                Cost(path.len() as i32 - 1),
            );
        }
    }

    #[export]
    fn add_edge(&mut self, _owner: &Reference, from: usize, to: usize, capacity: i32, cost: i32) {
        self.builder
            .add_edge(from, to, Capacity(capacity), Cost(cost));
    }

    #[export]
    fn add_source_edge(
        &mut self,
        _owner: &Reference,
        to: usize,
        commodity: String,
        capacity: i32,
        cost: i32,
    ) {
        self.builder.add_edge(
            Vertex::Source(commodity),
            to,
            Capacity(capacity),
            Cost(cost),
        );
    }

    #[export]
    fn add_sink_edge(
        &mut self,
        _owner: &Reference,
        from: usize,
        commodity: String,
        capacity: i32,
        cost: i32,
    ) {
        self.builder.add_edge(
            from,
            Vertex::Sink(commodity),
            Capacity(capacity),
            Cost(cost),
        );
    }

    #[export]
    pub fn set_converter(
        &mut self,
        _owner: &Reference,
        vertex: usize,
        from: String,
        from_amount: u32,
        to: String,
        to_amount: u32,
    ) {
        self.builder
            .set_converter(vertex, from, from_amount, to, to_amount);
    }

    #[export]
    fn solve(&mut self, _owner: &Reference, bidiretional: bool, load_dependence: f32) {
        self.builder.solve(bidiretional, load_dependence);
    }

    #[export]
    fn get_flows(&self, _owner: &Reference) -> GodotFlows {
        let flows = self.builder.get_flows();
        to_godot_flows(flows)
    }

    #[export]
    fn get_node_flows(&self, _owner: &Reference, node: usize) -> Option<Dictionary<Shared>> {
        let ids = self.builder.commodity_ids();
        let flows = self.builder.get_node_flows(node);

        if let Some(flows) = flows {
            let dict = Dictionary::new();

            for (name, id) in ids {
                dict.insert(name, (flows.sent[*id], flows.received[*id]));
            }

            Some(dict.into_shared())
        } else {
            None
        }
    }

    #[export]
    fn get_pair_flows(&self, _owner: &Reference) -> Dictionary<Shared> {
        let flows = self.builder.get_pair_flows();

        let dict = Dictionary::new();

        for ((p1, p2), flows) in flows.iter() {
            let fl = Dictionary::new();
            for (comm, flow) in flows {
                fl.insert(comm, flow);
            }
            dict.insert(NodePair(vertex_to_id(p1), vertex_to_id(p2)), fl);
        }

        dict.into_shared()
    }

    #[export]
    fn get_total_sources(&self, _owner: &Reference) -> Dictionary<Shared> {
        let sources = self.builder.get_total_sources();

        let dict = Dictionary::new();

        for (comm, amount) in sources.iter() {
            dict.insert(comm, amount);
        }

        dict.into_shared()
    }

    #[export]
    fn get_total_sinks(&self, _owner: &Reference) -> Dictionary<Shared> {
        let sinks = self.builder.get_total_sinks();

        let dict = Dictionary::new();

        for (comm, amount) in sinks.iter() {
            dict.insert(comm, amount);
        }

        dict.into_shared()
    }
}

fn to_godot_flows(flows: &[Flow<usize, String>]) -> GodotFlows {
    flows
        .iter()
        .map(|flow| {
            (
                vertex_to_id(&flow.a),
                vertex_to_id(&flow.b),
                flow.amount,
                flow.cost as u32,
                flow.capacity as u32,
            )
        })
        .collect::<Vec<_>>()
}

fn vertex_to_id(vertex: &Vertex<usize, String>) -> isize {
    match vertex {
        Vertex::Source(_) => -1,
        Vertex::Sink(_) => -2,
        Vertex::Node(id) => *id as isize,
    }
}
#[derive(Copy, Clone, Hash, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum Vertex<T: Clone + Ord, U: Clone + Ord> {
    Source(U),
    Sink(U),
    Node(T),
}

impl<T, U> From<T> for Vertex<T, U>
where
    T: Clone + Ord,
    U: Clone + Ord,
{
    fn from(x: T) -> Vertex<T, U> {
        Vertex::Node(x)
    }
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
    convert: Option<CommodityConversion>,
    is_source: Option<usize>,
    is_sink: Option<usize>,
    sent: Vec<i32>,
    received: Vec<i32>,
}

#[derive(Clone, Debug)]
struct CommodityConversion {
    from: usize,
    from_amount: u32,
    to: usize,
    to_amount: u32,
    storage: u32,
    source: Option<usize>,
}

impl NodeData {
    fn new(commodities: usize) -> Self {
        Self {
            supply: vec![0; commodities],
            convert: None,
            is_source: None,
            is_sink: None,
            sent: vec![0; commodities],
            received: vec![0; commodities],
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
    pub capacity: i32,
}

struct Graph {
    bidirectional: bool,
    commodities: usize,
    load_dependence: f32,
    nodes: Vec<NodeData>,
    edges: Vec<Edge>,
    out_edges: Vec<Vec<usize>>,
    pair_flows: HashMap<(usize, usize), Vec<u32>>,
}

impl Graph {
    pub fn add_edge(&mut self, a: Node, b: Node, data: EdgeData) -> &mut Self {
        assert!(a.0 < self.nodes.len());
        assert!(b.0 < self.nodes.len());
        self.edges.push(Edge { a, b, data });
        self.out_edges[a.0].push(self.edges.len() - 1);
        self
    }
}

impl Graph {
    pub fn delta_supply(&mut self, node: Node, commodity: usize, amount: i32) {
        self.nodes[node.0].supply[commodity] += amount;
    }
    pub fn new_default(
        num_vertices: usize,
        commodities: usize,
        bidirectional: bool,
        load_dependence: f32,
    ) -> Self {
        let nodes = vec![NodeData::new(commodities); num_vertices];
        let out_edges = vec![vec![]; num_vertices];
        Graph {
            bidirectional,
            commodities,
            load_dependence,
            nodes,
            edges: Vec::new(),
            out_edges,
            pair_flows: Default::default(),
        }
    }

    fn solve(&mut self) {
        let mut sources = vec![None; self.commodities];
        let mut sinks = vec![None; self.commodities];
        for (i, n) in self.nodes.iter().enumerate() {
            if let Some(s) = n.is_source {
                sources[s] = Some(i);
            }
            if let Some(s) = n.is_sink {
                sinks[s] = Some(i);
            }
        }

        let mut crowded = vec![false; self.commodities];
        let mut total_transported = vec![0; self.commodities];

        while !crowded.iter().all(|p| *p) {
            let candidates: Vec<_> = self
                .find_source_candidates(&sources, &sinks, &crowded)
                .collect();
            if candidates.is_empty() {
                break;
            }

            let (comm, start) = candidates.choose(&mut thread_rng()).unwrap();

            let result = self.find_path(*comm, *start);
            if let Some((path, _cost)) = result {
                self.apply_path(&path, *comm, 1);
                total_transported[*comm] += 1;
                crowded[*comm] = false;
            } else {
                crowded[*comm] = true;
            }
        }
    }

    fn find_source_candidates<'s>(
        &'s self,
        sources: &'s [Option<usize>],
        sinks: &'s [Option<usize>],
        crowded: &'s [bool],
    ) -> impl Iterator<Item = (usize, usize)> + 's {
        sources
            .iter()
            .zip(sinks)
            .zip(crowded)
            .enumerate()
            .filter_map(|(i, ((s, t), crowded))| {
                if let (Some(sn), Some(tn)) = (s, t) {
                    if !*crowded
                        && (self.nodes[*sn].supply[i] > 0)
                        && (self.nodes[*tn].supply[i] < 0)
                    {
                        Some((i, *sn))
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
    }

    fn apply_path(&mut self, path: &[usize], commodity: usize, amount: u32) {
        for i in 0..(path.len() - 1) {
            let n1 = path[i];
            let n2 = path[i + 1];
            self.apply_to_edge(n1, n2, amount);
            if self.bidirectional && i > 0 && i < path.len() - 2 {
                self.apply_to_edge(n2, n1, amount);
            }
        }
        self.nodes[path[0]].supply[commodity] -= amount as i32;
        self.nodes[path[path.len() - 1]].supply[commodity] += amount as i32;

        if path.len() > 2 {
            let p1 = path[1];
            let p2 = path[path.len() - 2];
            self.nodes[p1].sent[commodity] += amount as i32;
            self.nodes[p2].received[commodity] += amount as i32;

            match self.pair_flows.entry((p1, p2)) {
                Entry::Occupied(mut e) => {
                    e.get_mut()[commodity] += amount;
                }
                Entry::Vacant(e) => {
                    let mut vec = vec![0; self.commodities];
                    vec[commodity] = amount;
                    e.insert(vec);
                }
            }
        }

        // Converters
        let result = {
            let receiver_idx = path[path.len() - 2];
            let receiver = &mut self.nodes[receiver_idx];
            if let Some(convert) = &mut receiver.convert {
                if convert.from == commodity {
                    convert.storage += amount;
                    let mut total_amount = 0;
                    while convert.storage >= convert.from_amount {
                        total_amount += convert.to_amount;
                        convert.storage -= convert.from_amount;
                    }
                    let source = convert
                        .source
                        .expect("No source node for converter node found!");
                    let edge = self.out_edges[source]
                        .iter()
                        .find(|e| self.edges[**e].b.0 == receiver_idx)
                        .expect("No connection to source for converter node found!");
                    Some((source, *edge, convert.to, total_amount))
                } else {
                    None
                }
            } else {
                None
            }
        };
        if let Some((source, edge, to_comm, amount)) = result {
            self.nodes[source].supply[to_comm] += amount as i32;
            self.edges[edge].data.capacity += amount as i32;
        }
    }

    fn apply_to_edge(&mut self, from: usize, to: usize, amount: u32) {
        let edge_idx = self.out_edges[from]
            .iter()
            .find(|id| self.edges[**id].b.0 == to)
            .unwrap();

        self.edges[*edge_idx].data.flow += amount as i32;
    }

    fn find_path(&self, commodity: usize, start: usize) -> Option<(Vec<usize>, u32)> {
        dijkstra(
            &start,
            |id| self.get_successor(*id),
            |id| self.nodes[*id].supply[commodity] < 0,
        )
    }

    fn get_successor(&self, id: usize) -> impl Iterator<Item = (usize, u32)> + '_ {
        self.out_edges[id].iter().filter_map(|edge_id| {
            let edge = &self.edges[*edge_id];
            self.calc_cost(edge).map(|c| (edge.b.0, c))
        })
    }

    fn calc_cost(&self, edge: &Edge) -> Option<u32> {
        let remaining = edge.data.capacity - edge.data.flow;
        if remaining <= 0 {
            None
        } else {
            let rel_remaining = remaining as f32 / edge.data.capacity as f32;
            Some((edge.data.cost as f32 * rel_remaining.powf(-self.load_dependence)).round() as u32)
        }
    }
}

type EdgeList<T, U> = Vec<(Vertex<T, U>, Vertex<T, U>, Capacity, Cost)>;
type Converter<U> = (U, u32, U, u32);
type PairFlows<T, U> = BTreeMap<(Vertex<T, U>, Vertex<T, U>), Vec<(U, u32)>>;

#[allow(dead_code)]
pub struct GraphBuilder<T: Clone + Ord, U: Clone + Ord> {
    edge_list: EdgeList<T, U>,
    converters: Vec<(Vertex<T, U>, Converter<U>)>,
    flows: Option<Vec<Flow<T, U>>>,
    pair_flows: Option<PairFlows<T, U>>,
    nodes: Option<BTreeMap<Vertex<T, U>, NodeData>>,
    commodity_ids: Option<BTreeMap<U, usize>>,
    total_source: Option<BTreeMap<U, u32>>,
    total_sink: Option<BTreeMap<U, u32>>,
}

#[allow(dead_code)]
impl<T: Clone + Ord + Debug, U: Clone + Ord + Debug> GraphBuilder<T, U> {
    fn new() -> Self {
        Self {
            edge_list: Vec::new(),
            converters: Default::default(),
            flows: None,
            pair_flows: None,
            nodes: None,
            commodity_ids: None,
            total_source: None,
            total_sink: None,
        }
    }

    pub fn add_edge<A: Into<Vertex<T, U>>, B: Into<Vertex<T, U>>>(
        &mut self,
        a: A,
        b: B,
        capacity: Capacity,
        cost: Cost,
    ) -> &mut Self {
        assert!(
            self.flows.is_none(),
            "Cannot modify an already solved graph."
        );
        assert!(
            capacity.0 >= 0,
            "Capacity cannot be negative (capacity was {})",
            capacity.0
        );

        let a = a.into();
        let b = b.into();
        assert_ne!(a, b);
        assert!(!matches!(a, Vertex::Sink(_)));
        assert!(!matches!(b, Vertex::Source(_)));
        self.edge_list.push((a, b, capacity, cost));
        self
    }

    pub fn set_converter<A: Into<Vertex<T, U>>>(
        &mut self,
        vertex: A,
        from: U,
        from_amount: u32,
        to: U,
        to_amount: u32,
    ) {
        assert!(
            self.flows.is_none(),
            "Cannot modify an already solved graph."
        );

        self.converters
            .push((vertex.into(), (from, from_amount, to, to_amount)));
    }

    fn solve(&mut self, bidirectional: bool, load_dependence: f32) {
        assert!(
            self.flows.is_none(),
            "Cannot re-evaluate an already solved graph."
        );

        let mut next_id = 0;
        let mut next_comm_id = 0_usize;
        let mut index_mapper = BTreeMap::new();
        let mut node_mapper = BTreeMap::new();
        let mut commodity_mapper = BTreeMap::new();
        let mut commodities = vec![];
        for vertex in self
            .edge_list
            .iter()
            .flat_map(move |&(ref a, ref b, _, _)| iter::once(a).chain(iter::once(b)))
        {
            if let BEntry::Vacant(e) = index_mapper.entry(vertex) {
                e.insert(next_id);
                node_mapper.insert(next_id, vertex);
                next_id += 1;
            }

            if let Vertex::Source(comm) = vertex {
                if let BEntry::Vacant(e) = commodity_mapper.entry(comm) {
                    e.insert(next_comm_id);
                    commodities.push(comm.clone());
                    next_comm_id += 1;
                }
            }
            if let Vertex::Sink(comm) = vertex {
                if let BEntry::Vacant(e) = commodity_mapper.entry(comm) {
                    e.insert(next_comm_id);
                    commodities.push(comm.clone());
                    next_comm_id += 1;
                }
            }
        }

        let num_vertices = next_id;
        let mut g = Graph::new_default(
            num_vertices,
            commodity_mapper.len(),
            bidirectional,
            load_dependence,
        );

        for comm in commodities.iter() {
            let comm_id = commodity_mapper[&comm];
            if let Some(source) = index_mapper.get(&Vertex::Source(comm.clone())) {
                g.nodes[*source].is_source = Some(comm_id);
            }
            if let Some(sink) = index_mapper.get(&Vertex::Sink(comm.clone())) {
                g.nodes[*sink].is_sink = Some(comm_id);
            }
        }

        for (vertex, conv) in &self.converters {
            let idx = index_mapper[&vertex];

            assert!(
                g.nodes[idx].convert.is_none(),
                "Only one converter allowed per node!"
            );
            g.nodes[idx].convert = Some(CommodityConversion {
                from: commodity_mapper[&conv.0],
                from_amount: conv.1,
                to: commodity_mapper[&conv.2],
                to_amount: conv.3,
                storage: 0,
                source: None,
            })
        }

        for &(ref a, ref b, cap, cost) in &self.edge_list {
            let node_a = Node(*index_mapper.get(&a).unwrap());
            let node_b = Node(*index_mapper.get(&b).unwrap());
            if let Vertex::Source(comm) = a {
                let comm_id = commodity_mapper[comm];
                g.delta_supply(
                    Node(*index_mapper.get(&a).unwrap()),
                    *commodity_mapper.get(comm).unwrap(),
                    cap.0,
                );
                if let Some(convert) = &mut g.nodes[node_b.0].convert {
                    if convert.to == comm_id {
                        convert.source = Some(node_a.0);
                    }
                }
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

        let mut total_sources: BTreeMap<_, _> = commodities.iter().map(|c| (c, 0_u32)).collect();
        let mut total_sinks: BTreeMap<_, _> = commodities.iter().map(|c| (c, 0_u32)).collect();

        let flows: Vec<_> = g
            .edges
            .iter()
            .map(|e| {
                let a = node_mapper[&e.a.0];
                let b = node_mapper[&e.b.0];
                if let Vertex::Source(comm) = a {
                    *total_sources.entry(comm).or_default() += e.data.capacity as u32;
                }
                if let Vertex::Sink(comm) = b {
                    *total_sinks.entry(comm).or_default() += e.data.capacity as u32;
                }
                Flow {
                    a: a.clone(),
                    b: b.clone(),
                    amount: e.data.flow as u32,
                    cost: e.data.cost,
                    capacity: e.data.capacity,
                }
            })
            .collect();

        let pair_flows: PairFlows<T, U> = g
            .pair_flows
            .iter()
            .map(|((p1, p2), flow)| {
                (
                    (node_mapper[p1].clone(), node_mapper[p2].clone()),
                    flow.iter()
                        .enumerate()
                        .map(|(comm, value)| (commodities[comm].clone(), *value))
                        .collect(),
                )
            })
            .collect();

        let nodes: BTreeMap<_, _> = g
            .nodes
            .into_iter()
            .enumerate()
            .map(|(i, nd)| (node_mapper[&i].clone(), nd))
            .collect();

        self.flows = Some(flows);
        self.pair_flows = Some(pair_flows);
        self.total_source = Some(
            total_sources
                .iter()
                .map(|(k, v)| ((*k).clone(), *v))
                .collect(),
        );
        self.total_sink = Some(
            total_sinks
                .iter()
                .map(|(k, v)| ((*k).clone(), *v))
                .collect(),
        );
        self.nodes = Some(nodes);
        self.commodity_ids = Some(
            commodity_mapper
                .iter()
                .map(|(k, v)| ((*k).clone(), *v))
                .collect(),
        );
    }

    fn commodity_ids(&self) -> &BTreeMap<U, usize> {
        self.commodity_ids
            .as_ref()
            .expect("Unable to extract commodity id from unsolved graph")
    }

    fn get_flows(&self) -> &[Flow<T, U>] {
        self.flows
            .as_ref()
            .expect("Unable to extract flows from unsolved graph")
    }

    fn get_pair_flows(&self) -> &PairFlows<T, U> {
        self.pair_flows
            .as_ref()
            .expect("Unable to extract pair flows from unsolved graph")
    }

    fn get_node_flows(&self, node: T) -> Option<&NodeData> {
        self.nodes
            .as_ref()
            .expect("Unable to extract node flows from unsolved graph")
            .get(&Vertex::Node(node))
    }

    fn get_total_sources(&self) -> &BTreeMap<U, u32> {
        self.total_source
            .as_ref()
            .expect("Unable to extract sources from unsolved graph")
    }

    fn get_total_sinks(&self) -> &BTreeMap<U, u32> {
        self.total_sink
            .as_ref()
            .expect("Unable to extract sources from unsolved graph")
    }
}

#[cfg(test)]
mod tests {
    use super::Vertex::Node;
    use super::*;
    use std::collections::HashMap;

    #[test]
    fn test_build_network() {
        let mut builder: GraphBuilder<&str, _> = GraphBuilder::new();

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

        //let _flows = builder.solve(1.0);
    }

    #[test]
    fn test_converter() {
        let mut builder: GraphBuilder<&str, _> = GraphBuilder::new();

        builder.add_edge(Vertex::Source("A"), "SrcA", Capacity(10), Cost(0));
        builder.add_edge("SrcA", "ConvAB", Capacity(10), Cost(0));
        builder.add_edge("ConvAB", "SinkB", Capacity(10), Cost(0));
        builder.add_edge(Vertex::Source("B"), "ConvAB", Capacity(0), Cost(0));
        builder.add_edge("ConvAB", Vertex::Sink("A"), Capacity(10), Cost(0));
        builder.add_edge("SinkB", Vertex::Sink("B"), Capacity(10), Cost(0));

        builder.set_converter("ConvAB", "A", 1, "B", 1);

        builder.solve(false, 0.2);
        let flows = builder.get_flows();
        let map: HashMap<_, _> = flows.iter().map(|f| ((f.a, f.b), f.amount)).collect();

        println!("{:?}", map);
        assert_eq!(map[&(Node("SrcA"), Node("ConvAB"))], 10);
        assert_eq!(map[&(Node("ConvAB"), Node("SinkB"))], 10);
    }
}
