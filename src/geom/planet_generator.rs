use gdnative::api::ArrayMesh;
use gdnative::prelude::*;

use crate::geom::godot_util::to_mesh;
use crate::geom::ico_sphere::IcoSphereGenerator;

pub struct NodeData {
    pub position: Vector3,
    pub elevation: f32,
    pub neighbors: Vec<usize>,
}

#[derive(NativeClass)]
#[no_constructor]
#[inherit(Reference)]
pub struct PlanetData {
    nodes: Vec<NodeData>,
    mesh: Ref<ArrayMesh, Shared>,
}

#[methods]
impl PlanetData {
    #[export]
    fn _init(&mut self, _owner: &Reference) {}

    #[export]
    fn get_mesh(&self, _owner: &Reference) -> &Ref<ArrayMesh> {
        &self.mesh
    }

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
}

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct PlanetGenerator;

#[methods]
impl PlanetGenerator {
    fn new(_owner: &Reference) -> Self {
        Self {}
    }

    #[export]
    fn generate(
        &self,
        _owner: &Reference,
        radius: f32,
        subdivisions: u32,
    ) -> Instance<PlanetData, Unique> {
        let (vertices, faces) = IcoSphereGenerator::new(radius, subdivisions).generate();

        let mut data = PlanetData {
            nodes: vec![],
            mesh: to_mesh(&vertices, &faces).into_shared(),
        };

        for v in vertices {
            data.nodes.push(NodeData {
                position: v,
                elevation: 0.0,
                neighbors: vec![],
            });
        }

        for face in faces {
            data.nodes[face.0].neighbors.push(face.1);
            data.nodes[face.1].neighbors.push(face.2);
            data.nodes[face.2].neighbors.push(face.0);
        }

        data.emplace()
    }
}
