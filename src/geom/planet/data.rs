use gdnative::prelude::*;
use kdtree::{distance::squared_euclidean, KdTree};
use pathfinding::directed::astar::astar;

pub const DIST_FACTOR: u32 = 1_000_000;

const NAV_ALL: u32 = 0;
const NAV_LAND: u32 = 1;
const NAV_WATER: u32 = 2;

pub struct NodeData {
    pub position: Vector3,
    pub elevation: f32,
    pub is_water: bool,
    pub neighbors: Vec<usize>,
    pub distances: Vec<u32>,
}

#[derive(NativeClass)]
#[no_constructor]
#[inherit(Reference)]
#[allow(non_snake_case)]
pub struct PlanetData {
    pub nodes: Vec<NodeData>,
    tree: KdTree<f32, usize, [f32; 3]>,

    #[property]
    pub NAV_ALL: u32,
    #[property]
    pub NAV_LAND: u32,
    #[property]
    pub NAV_WATER: u32,
}

impl PlanetData {
    pub fn new(nodes: Vec<NodeData>) -> Self {
        let mut tree = KdTree::with_capacity(3, nodes.len());
        for (i, node) in nodes.iter().enumerate() {
            tree.add(node.position.to_array(), i).unwrap();
        }
        Self {
            nodes,
            tree,
            NAV_ALL,
            NAV_LAND,
            NAV_WATER,
        }
    }
}

#[methods]
impl PlanetData {
    #[export]
    fn _init(&mut self, _owner: &Reference) {}

    #[export]
    fn get_node_count(&self, _owner: &Reference) -> usize {
        self.nodes.len()
    }

    #[export]
    fn get_position(&self, _owner: &Reference, idx: usize) -> Vector3 {
        self.nodes[idx].position
    }

    #[export]
    fn get_elevation(&self, _owner: &Reference, idx: usize) -> f32 {
        self.nodes[idx].elevation
    }

    #[export]
    fn get_neighbors(&self, _owner: &Reference, idx: usize) -> &[usize] {
        &self.nodes[idx].neighbors[..]
    }

    #[export]
    fn get_closest_point(&self, _owner: &Reference, point: Vector3) -> Option<usize> {
        self.tree
            .nearest(&point.to_array(), 1, &squared_euclidean)
            .map_or_else(|_err| None, |n| Some(*n[0].1))
    }

    #[export]
    fn get_id_path(
        &self,
        _owner: &Reference,
        from: usize,
        to: usize,
        nav_type: u32,
    ) -> Option<Vec<usize>> {
        self.find_path(from, to, nav_type).map(|(v, _c)| v)
    }

    fn find_path(&self, from: usize, to: usize, nav_type: u32) -> Option<(Vec<usize>, u32)> {
        let goal = self.nodes[to].position;
        astar(
            &from,
            |id| self.get_successor(*id, nav_type),
            |id| (self.nodes[*id].position.distance_to(goal) * DIST_FACTOR as f32) as u32,
            |id| id == &to,
        )
    }

    fn get_successor<'s>(
        &'s self,
        id: usize,
        nav_type: u32,
    ) -> impl Iterator<Item = (usize, u32)> + 's {
        let node = &self.nodes[id];
        let water = node.is_water;
        node.neighbors.iter().enumerate().filter_map(move |(i, n)| {
            if nav_type == self.NAV_ALL || (nav_type == self.NAV_WATER) == water {
                Some((*n, node.distances[i]))
            } else {
                None
            }
        })
    }
}
