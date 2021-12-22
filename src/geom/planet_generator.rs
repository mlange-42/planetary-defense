use gdnative::api::{ArrayMesh, Curve};
use gdnative::prelude::*;

use noise::{BasicMulti, Billow, Fbm, HybridMulti, MultiFractal, NoiseFn, RidgedMulti};

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
    collision_mesh: Ref<ArrayMesh, Shared>,
}

#[methods]
impl PlanetData {
    #[export]
    fn _init(&mut self, _owner: &Reference) {}

    #[export]
    fn get_collision_mesh(&self, _owner: &Reference) -> &Ref<ArrayMesh> {
        &self.collision_mesh
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

struct PlanetGeneratorParams {
    radius: f32,
    subdivisions: u32,
    terrain_max_height: f32,
    terrain_height_step: f32,
    terrain_noise_type: String,
    terrain_noise_period: f32,
    terrain_noise_octaves: usize,
    terrain_curve: Ref<Curve>,
}

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct PlanetGenerator {
    params: Option<PlanetGeneratorParams>,
}

#[methods]
impl PlanetGenerator {
    fn new(_owner: &Reference) -> Self {
        Self { params: None }
    }

    #[export]
    #[allow(clippy::too_many_arguments)]
    fn initialize(
        &mut self,
        _owner: &Reference,
        radius: f32,
        subdivisions: u32,
        terrain_max_height: f32,
        terrain_height_step: f32,
        terrain_noise_type: String,
        terrain_noise_period: f32,
        terrain_noise_octaves: usize,
        terrain_curve: Ref<Curve>,
    ) {
        self.params = Some(PlanetGeneratorParams {
            radius,
            subdivisions,
            terrain_max_height,
            terrain_height_step,
            terrain_noise_type,
            terrain_noise_period,
            terrain_noise_octaves,
            terrain_curve,
        })
    }

    #[export]
    fn generate(&self, _owner: &Reference) -> Instance<PlanetData, Unique> {
        let params = self.params.as_ref().unwrap();

        let (mut vertices, faces) =
            IcoSphereGenerator::new(params.radius, params.subdivisions).generate();

        let mut nodes = self.generate_terrain(&mut vertices);

        for face in faces.iter() {
            nodes[face.0].neighbors.push(face.1);
            nodes[face.1].neighbors.push(face.2);
            nodes[face.2].neighbors.push(face.0);
        }

        let data = PlanetData {
            nodes,
            collision_mesh: to_mesh(&vertices, &faces).into_shared(),
        };
        data.emplace()
    }

    fn generate_terrain(&self, vertices: &mut [Vector3]) -> Vec<NodeData> {
        let params = self.params.as_ref().unwrap();

        let noise = create_noise(
            &params.terrain_noise_type,
            1.0 / (params.terrain_noise_period * params.radius),
            params.terrain_noise_octaves,
        );

        let h_max = params.terrain_max_height;
        let h_step = params.terrain_height_step;
        let curve = unsafe { &params.terrain_curve.clone().assume_unique() };

        vertices
            .iter_mut()
            .map(|v| {
                let normal = v.normalize();
                let n = noise.get([v.x as f64, v.y as f64, v.z as f64]);
                let rel_elevation = 2.0 * curve.interpolate(n / 2.0 + 0.5) - 1.0;
                let mut elevation = rel_elevation as f32 * h_max;
                if h_step > 0.0 {
                    elevation = (elevation / h_step).round() * h_step
                }
                *v += normal * elevation;

                NodeData {
                    position: *v,
                    elevation,
                    neighbors: vec![],
                }
            })
            .collect()
    }
}

fn create_noise(noise_type: &str, frequency: f32, octaves: usize) -> Box<dyn NoiseFn<[f64; 3]>> {
    match noise_type {
        "basic" => Box::new(
            BasicMulti::new()
                .set_frequency(frequency as f64)
                .set_octaves(octaves),
        ),
        "billow" => Box::new(
            Billow::new()
                .set_frequency(frequency as f64)
                .set_octaves(octaves),
        ),
        "fbm" => Box::new(
            Fbm::new()
                .set_frequency(frequency as f64)
                .set_octaves(octaves),
        ),
        "hybrid" => Box::new(
            HybridMulti::new()
                .set_frequency(frequency as f64)
                .set_octaves(octaves),
        ),
        "ridged" => Box::new(
            RidgedMulti::new()
                .set_frequency(frequency as f64)
                .set_octaves(octaves),
        ),
        _ => panic!("Unknown noise type {}", noise_type),
    }
}
