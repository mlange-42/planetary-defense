use std::collections::HashSet;
use std::marker::PhantomData;

use crate::geom::planet::serialize::to_csv;
use euclid::UnknownUnit;
use gdnative::prelude::*;
use kdtree::{distance::squared_euclidean, KdTree};
use pathfinding::directed::astar::astar;
use serde::{Deserialize, Serialize};

pub const DIST_FACTOR: u32 = 1_000_000;

const NAV_ALL: u32 = 0;
const NAV_LAND: u32 = 1;
const NAV_WATER: u32 = 2;

#[derive(Serialize, Deserialize)]
#[serde(remote = "Vector3")]
struct Vector3Def {
    pub x: f32,
    pub y: f32,
    pub z: f32,
    #[serde(skip)]
    pub _unit: PhantomData<UnknownUnit>,
}

#[derive(NativeClass, ToVariant, Clone, Default, Serialize, Deserialize)]
#[no_constructor]
#[inherit(Reference)]
pub struct NodeData {
    #[property]
    #[serde(with = "Vector3Def")]
    pub position: Vector3,
    #[property]
    pub elevation: f32,
    #[property]
    pub is_water: bool,
    #[property]
    #[serde(skip)]
    pub is_port: bool,
    #[property]
    #[serde(skip)]
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

#[derive(Default, Serialize, Deserialize)]
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
    pub vertices: Vec<Vector3>,
    pub neighbors: Vec<NodeNeighbors>,
    pub faces: Vec<(usize, usize, usize)>,
    tree: KdTree<f32, usize, [f32; 3]>,

    #[property]
    pub NAV_ALL: u32,
    #[property]
    pub NAV_LAND: u32,
    #[property]
    pub NAV_WATER: u32,
}

impl PlanetData {
    pub fn new(
        nodes: Vec<NodeData>,
        vertices: Vec<Vector3>,
        neighbors: Vec<NodeNeighbors>,
        faces: Vec<(usize, usize, usize)>,
    ) -> Self {
        let mut tree = KdTree::with_capacity(3, nodes.len());
        for (i, node) in nodes.iter().enumerate() {
            tree.add(node.position.to_array(), i).unwrap();
        }
        Self {
            nodes,
            vertices,
            neighbors,
            faces,
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
    fn get_neighbors(&self, _owner: &Reference, idx: usize) -> &[usize] {
        &self.neighbors[idx].neighbors
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
    fn set_port(&mut self, _owner: &Reference, idx: usize, port: bool) {
        self.nodes[idx].is_port = port;
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
            .unwrap_or_else(Vec::new)
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
            .unwrap_or_else(Vec::new)
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
        let source = &self.nodes[id];
        neigh
            .neighbors
            .iter()
            .enumerate()
            .filter_map(move |(i, n)| {
                let target = &self.nodes[*n];
                if !target.is_occupied
                    && (nav_type == self.NAV_ALL
                        || (nav_type == self.NAV_WATER) == target.is_water
                        || (nav_type == self.NAV_LAND
                            && ((target.is_port && !source.is_water)
                                || (source.is_port && !target.is_water))))
                {
                    Some((*n, neigh.distances[i]))
                } else {
                    None
                }
            })
    }

    #[export]
    fn to_csv(&self, _owner: &Reference, path: String) {
        to_csv(self, &path).unwrap()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_in_radius() {
        let nodes = vec![NodeData::default(); 4];
        let vertices = vec![Vector3::default(); 4];
        let faces: Vec<(usize, usize, usize)> = Vec::new();

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
        let data = PlanetData::new(nodes, vertices, neighbors, faces);

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
