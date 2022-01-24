use std::collections::HashSet;
use std::marker::PhantomData;

use crate::geom::planet::serialize::to_csv;
use crate::geom::util::xyz_to_ll;
use crate::FlowNetwork;
use euclid::UnknownUnit;
use gdnative::prelude::*;
use kdtree::{distance::squared_euclidean, KdTree};
use pathfinding::directed::astar::astar;
use serde::{Deserialize, Serialize};

pub const DIST_FACTOR: u32 = 1_000_000;

const NAV_ALL: u32 = 0;
const NAV_LAND: u32 = 1;
const NAV_WATER: u32 = 2;

/// ID offset between different transport modes
const TYPE_OFFSET: usize = 1_000_000;

pub fn to_base_id(id: usize) -> usize {
    id % TYPE_OFFSET
}

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

    #[export]
    fn lon_lat(&self, _owner: &Reference) -> Vector2 {
        xyz_to_ll(self.position.normalize())
    }
}

#[derive(Default, Serialize, Deserialize)]
pub struct NodeNeighbors {
    pub neighbors: Vec<usize>,
    pub distances: Vec<u32>,
}

#[derive(Serialize, Deserialize)]
pub struct PlanetProperties {
    pub radius: f32,
    pub cell_radius: f32,
    pub max_elevation: f32,
}

#[derive(NativeClass)]
#[no_constructor]
#[inherit(Reference)]
#[allow(non_snake_case)]
pub struct PlanetData {
    pub properties: PlanetProperties,
    pub nodes: Vec<NodeData>,
    pub vertices: Vec<Vector3>,
    pub neighbors: Vec<NodeNeighbors>,
    pub faces: Vec<(usize, usize, usize)>,
    pub network: Option<Instance<FlowNetwork, Shared>>,
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
        properties: PlanetProperties,
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
            properties,
            nodes,
            vertices,
            neighbors,
            faces,
            network: None,
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
    fn set_network(&mut self, _owner: &Reference, network: Variant) {
        let network = network
            .try_to_object::<Reference>()
            .expect("Failed to convert network variant to object");
        let network = network
            .cast_instance::<FlowNetwork>()
            .expect("Failed to cast network object to instance");
        self.network = Some(network);
    }

    #[export]
    fn get_network(&self, _owner: &Reference) -> &Instance<FlowNetwork, Shared> {
        self.network
            .as_ref()
            .expect("No network set for planet data!")
    }

    #[export]
    fn get_radius(&self, _owner: &Reference) -> f32 {
        self.properties.radius
    }

    #[export]
    fn get_cell_radius(&self, _owner: &Reference) -> f32 {
        self.properties.cell_radius
    }

    #[export]
    fn get_max_elevation(&self, _owner: &Reference) -> f32 {
        self.properties.max_elevation
    }

    #[export]
    fn get_node_count(&self, _owner: &Reference) -> usize {
        self.nodes.len()
    }

    #[export]
    fn get_position(&self, _owner: &Reference, idx: usize) -> Vector3 {
        self.nodes[to_base_id(idx)].position
    }

    #[export]
    fn get_neighbors(&self, _owner: &Reference, idx: usize) -> &[usize] {
        &self.neighbors[to_base_id(idx)].neighbors
    }

    #[export]
    fn get_node(&self, _owner: &Reference, idx: usize) -> &NodeData {
        &self.nodes[to_base_id(idx)]
    }

    #[export]
    fn set_occupied(&mut self, _owner: &Reference, idx: usize, occ: bool) {
        self.nodes[to_base_id(idx)].is_occupied = occ;
    }

    #[export]
    fn set_port(&mut self, _owner: &Reference, idx: usize, port: bool) {
        self.nodes[to_base_id(idx)].is_port = port;
    }

    #[export]
    fn get_closest_point(&self, _owner: &Reference, point: Vector3) -> Option<usize> {
        self.tree
            .nearest(&point.to_array(), 1, &squared_euclidean)
            .map_or_else(|_err| None, |n| Some(*n[0].1))
    }

    #[export]
    fn has_point(&self, _owner: &Reference, id: usize, nav_type: u32) -> bool {
        let id = to_base_id(id);
        if id < self.nodes.len() {
            nav_type == self.NAV_ALL || self.nodes[id].is_water == (nav_type == self.NAV_WATER)
        } else {
            false
        }
    }

    #[export]
    fn get_in_radius(&self, _owner: &Reference, id: usize, radius: u32) -> Vec<(usize, u32)> {
        let id = to_base_id(id);
        self.get_nodes_in_radius(id, radius)
    }

    fn get_nodes_in_radius(&self, id: usize, radius: u32) -> Vec<(usize, u32)> {
        let id = to_base_id(id);

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
    fn get_id_path(
        &self,
        _owner: &Reference,
        from: usize,
        to: usize,
        nav_type: u32,
        max_slope: f32,
    ) -> Vec<usize> {
        let from = to_base_id(from);
        let to = to_base_id(to);
        self.find_path(from, to, nav_type, max_slope)
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
        max_slope: f32,
    ) -> Vec<Vector3> {
        let from = to_base_id(from);
        let to = to_base_id(to);
        self.find_path(from, to, nav_type, max_slope)
            .map(|(v, _c)| v.iter().map(|id| self.nodes[*id].position).collect())
            .unwrap_or_else(Vec::new)
    }

    fn find_path(
        &self,
        from: usize,
        to: usize,
        nav_type: u32,
        max_slope: f32,
    ) -> Option<(Vec<usize>, u32)> {
        let goal = self.nodes[to].position;
        astar(
            &from,
            |id| self.get_successor(*id, nav_type, max_slope),
            |id| (self.nodes[*id].position.distance_to(goal) * DIST_FACTOR as f32) as u32,
            |id| id == &to,
        )
    }

    fn get_successor(
        &self,
        id: usize,
        nav_type: u32,
        max_slope: f32,
    ) -> impl Iterator<Item = (usize, u32)> + '_ {
        let neigh = &self.neighbors[id];
        let source = &self.nodes[id];
        neigh
            .neighbors
            .iter()
            .enumerate()
            .filter_map(move |(i, n)| {
                let target = &self.nodes[*n];
                if !target.is_occupied {
                    let nav_water = nav_type == self.NAV_WATER;
                    let slope = if source.elevation < 0.0 || target.elevation < 0.0 {
                        0.0
                    } else {
                        (source.elevation - target.elevation).abs()
                    };
                    if (max_slope <= 0.0 || slope <= max_slope)
                        && (nav_type == self.NAV_ALL
                            || (nav_water == source.is_water && nav_water == target.is_water)
                            || (nav_type == self.NAV_LAND
                                && ((target.is_port && !source.is_water)
                                    || (source.is_port && !target.is_water))))
                    {
                        Some((*n, neigh.distances[i]))
                    } else {
                        None
                    }
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

        let props = PlanetProperties {
            radius: 1.0,
            cell_radius: 0.01,
            max_elevation: 0.1,
        };
        let data = PlanetData::new(props, nodes, vertices, neighbors, faces);

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
