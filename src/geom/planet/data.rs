use std::collections::HashSet;
use std::{
    fs::File,
    io::{BufWriter, Write},
};

use gdnative::prelude::*;
use kdtree::{distance::squared_euclidean, KdTree};
use pathfinding::directed::astar::astar;

pub const DIST_FACTOR: u32 = 1_000_000;

const NAV_ALL: u32 = 0;
const NAV_LAND: u32 = 1;
const NAV_WATER: u32 = 2;

#[derive(NativeClass, ToVariant, Clone, Default)]
#[no_constructor]
#[inherit(Reference)]
pub struct NodeData {
    #[property]
    pub position: Vector3,
    #[property]
    pub elevation: f32,
    #[property]
    pub is_water: bool,
    #[property]
    pub is_occupied: bool,
    #[property]
    pub temperature: f32,
    #[property]
    pub precipitation: f32,
    #[property]
    pub vegetation_type: u32,
}

#[methods]
impl NodeData {
    #[export]
    fn _init(&mut self, _owner: &Reference) {}
}

#[derive(Default)]
pub struct NodeNeighbors {
    pub neighbors: Vec<usize>,
    pub distances: Vec<u32>,
}

#[derive(NativeClass)]
#[no_constructor]
#[inherit(Reference)]
#[allow(non_snake_case)]
pub struct PlanetData {
    pub nodes: Vec<NodeData>,
    pub neighbors: Vec<NodeNeighbors>,
    tree: KdTree<f32, usize, [f32; 3]>,

    #[property]
    pub NAV_ALL: u32,
    #[property]
    pub NAV_LAND: u32,
    #[property]
    pub NAV_WATER: u32,
}

impl PlanetData {
    pub fn new(nodes: Vec<NodeData>, neighbors: Vec<NodeNeighbors>) -> Self {
        let mut tree = KdTree::with_capacity(3, nodes.len());
        for (i, node) in nodes.iter().enumerate() {
            tree.add(node.position.to_array(), i).unwrap();
        }
        Self {
            nodes,
            neighbors,
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
    fn get_node(&self, _owner: &Reference, idx: usize) -> &NodeData {
        &self.nodes[idx]
    }

    #[export]
    fn set_occupied(&mut self, _owner: &Reference, idx: usize, occ: bool) {
        self.nodes[idx].is_occupied = occ;
    }
    #[export]
    fn get_closest_point(&self, _owner: &Reference, point: Vector3) -> Option<usize> {
        self.tree
            .nearest(&point.to_array(), 1, &squared_euclidean)
            .map_or_else(|_err| None, |n| Some(*n[0].1))
    }

    #[export]
    fn has_point(&self, _owner: &Reference, id: usize, nav_type: u32) -> bool {
        if id < self.nodes.len() {
            nav_type == self.NAV_ALL || self.nodes[id].is_water == (nav_type == self.NAV_WATER)
        } else {
            false
        }
    }

    #[export]
    fn get_in_radius(&self, _owner: &Reference, id: usize, radius: u32) -> Vec<(usize, u32)> {
        self.get_nodes_in_radius(id, radius)
    }

    fn get_nodes_in_radius(&self, id: usize, radius: u32) -> Vec<(usize, u32)> {
        let mut vec = Vec::new();
        let mut visited = HashSet::new();
        let mut open = HashSet::new();
        let mut new_open = HashSet::new();

        vec.push((id, 0_u32));
        visited.insert(id);
        open.insert(id);

        for r in 0..radius {
            for curr in open.drain() {
                let neigh: Vec<_> = self.neighbors[curr]
                    .neighbors
                    .iter()
                    .filter(|n| !visited.contains(n))
                    .cloned()
                    .collect();

                vec.extend(neigh.iter().map(|n| (*n, r + 1)));
                visited.extend(&neigh);
                new_open.extend(&neigh);
            }
            std::mem::swap(&mut open, &mut new_open);
        }

        vec
    }

    #[export]
    fn get_id_path(&self, _owner: &Reference, from: usize, to: usize, nav_type: u32) -> Vec<usize> {
        self.find_path(from, to, nav_type)
            .map(|(v, _c)| v)
            .unwrap_or_else(|| vec![])
    }

    #[export]
    fn get_point_path(
        &self,
        _owner: &Reference,
        from: usize,
        to: usize,
        nav_type: u32,
    ) -> Vec<Vector3> {
        self.find_path(from, to, nav_type)
            .map(|(v, _c)| v.iter().map(|id| self.nodes[*id].position).collect())
            .unwrap_or_else(|| vec![])
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

    fn get_successor(&self, id: usize, nav_type: u32) -> impl Iterator<Item = (usize, u32)> + '_ {
        let neigh = &self.neighbors[id];
        neigh
            .neighbors
            .iter()
            .enumerate()
            .filter_map(move |(i, n)| {
                let target = &self.nodes[*n];
                if !target.is_occupied
                    && (nav_type == self.NAV_ALL || (nav_type == self.NAV_WATER) == target.is_water)
                {
                    Some((*n, neigh.distances[i]))
                } else {
                    None
                }
            })
    }

    #[export]
    pub fn to_csv(&self, _owner: &Reference, file: String) {
        let f = File::create(file).expect("Unable to create file");
        let mut f = BufWriter::new(f);

        writeln!(
            f,
            "x;y;z;lat;elevation;temperature;precipitation;vegetation_type"
        )
        .unwrap();
        for node in &self.nodes {
            let lat = node.position.normalize().y.asin().to_degrees().abs();
            writeln!(
                f,
                "{};{};{};{};{};{};{};{}",
                node.position.x,
                node.position.y,
                node.position.z,
                lat,
                node.elevation,
                node.temperature,
                node.precipitation,
                node.vegetation_type
            )
            .unwrap();
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_in_radius() {
        let nodes = vec![NodeData::default(); 4];

        let neighbors = vec![
            NodeNeighbors {
                neighbors: vec![1],
                distances: vec![1],
            },
            NodeNeighbors {
                neighbors: vec![0, 2],
                distances: vec![1, 1],
            },
            NodeNeighbors {
                neighbors: vec![1, 3],
                distances: vec![1, 1],
            },
            NodeNeighbors {
                neighbors: vec![2],
                distances: vec![1],
            },
        ];
        let data = PlanetData::new(nodes, neighbors);

        assert_eq!(data.get_nodes_in_radius(0, 0), [(0, 0)]);
        assert_eq!(data.get_nodes_in_radius(0, 1), [(0, 0), (1, 1)]);
        assert_eq!(data.get_nodes_in_radius(0, 2), [(0, 0), (1, 1), (2, 2)]);
        assert_eq!(
            data.get_nodes_in_radius(0, 3),
            [(0, 0), (1, 1), (2, 2), (3, 3)]
        );
        assert_eq!(
            data.get_nodes_in_radius(0, 4),
            [(0, 0), (1, 1), (2, 2), (3, 3)]
        );

        assert_eq!(data.get_nodes_in_radius(1, 0), [(1, 0)]);
        assert_eq!(data.get_nodes_in_radius(1, 1), [(1, 0), (0, 1), (2, 1)]);
        assert_eq!(
            data.get_nodes_in_radius(1, 2),
            [(1, 0), (0, 1), (2, 1), (3, 2)]
        );
        assert_eq!(
            data.get_nodes_in_radius(1, 3),
            [(1, 0), (0, 1), (2, 1), (3, 2)]
        );
    }
}
