use gdnative::api::Curve;
use gdnative::prelude::*;

use noise::{
    BasicMulti, Billow, Fbm, HybridMulti, MultiFractal, NoiseFn, OpenSimplex, Perlin, RidgedMulti,
    SuperSimplex,
};

use crate::geom::godot_util::{to_collision_shape, to_mesh};
use crate::geom::ico_sphere::IcoSphereGenerator;
use crate::geom::planet::data::{NodeData, NodeNeighbors, PlanetData, DIST_FACTOR};

struct PlanetGeneratorParams {
    radius: f32,
    subdivisions: u32,
    terrain_max_height: f32,
    terrain_height_step: f32,
    terrain_noise_type: String,
    terrain_noise_period: f32,
    terrain_noise_octaves: usize,
    terrain_curve: Ref<Curve>,
    climate_noise_type: String,
    climate_noise_period: f32,
    climate_noise_octaves: usize,
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
        climate_noise_type: String,
        climate_noise_period: f32,
        climate_noise_octaves: usize,
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
            climate_noise_type,
            climate_noise_period,
            climate_noise_octaves,
        })
    }

    #[export]
    fn generate(&self, _owner: &Reference) -> VariantArray<Unique> {
        let params = self.params.as_ref().unwrap();

        let (mut vertices, faces) =
            IcoSphereGenerator::new(params.radius, params.subdivisions).generate();

        let nodes = self.generate_terrain(&mut vertices);
        let mut neighbors: Vec<_> = nodes.iter().map(|_| NodeNeighbors::default()).collect();

        for face in faces.iter() {
            neighbors[face.0].neighbors.push(face.1);
            neighbors[face.0]
                .distances
                .push((vertices[face.0].distance_to(vertices[face.1]) * DIST_FACTOR as f32) as u32);

            neighbors[face.1].neighbors.push(face.2);
            neighbors[face.1]
                .distances
                .push((vertices[face.1].distance_to(vertices[face.2]) * DIST_FACTOR as f32) as u32);

            neighbors[face.2].neighbors.push(face.0);
            neighbors[face.2]
                .distances
                .push((vertices[face.2].distance_to(vertices[face.0]) * DIST_FACTOR as f32) as u32);
        }

        let colors = self.generate_colors(&nodes);

        let data = PlanetData::new(nodes, neighbors);

        let mesh = to_mesh(&vertices, &faces, Some(colors));
        let shape = to_collision_shape(&vertices, &faces);

        let arr = VariantArray::new();
        arr.push(data.emplace());
        arr.push(mesh);
        arr.push(shape);

        arr
    }

    fn generate_terrain(&self, vertices: &mut [Vector3]) -> Vec<NodeData> {
        let params = self.params.as_ref().unwrap();

        let noise = create_noise(&params.terrain_noise_type, params.terrain_noise_octaves);
        let climate_noise = create_noise(&params.climate_noise_type, params.climate_noise_octaves);

        let h_max = params.terrain_max_height;
        let h_step = params.terrain_height_step;
        let curve = unsafe { &params.terrain_curve.clone().assume_unique() };

        let scale = 1.0 / (params.terrain_noise_period * params.radius);
        let climate_scale = 1.0 / (params.climate_noise_period * params.radius);

        vertices
            .iter_mut()
            .map(|v| {
                let normal = v.normalize();
                let el = noise.get([
                    (scale * v.x) as f64,
                    (scale * v.y) as f64,
                    (scale * v.z) as f64,
                ]);
                let cl = climate_noise.get([
                    (climate_scale * v.x) as f64,
                    (climate_scale * v.y) as f64,
                    (climate_scale * v.z) as f64,
                ]) as f32
                    / 2.0
                    + 0.5;
                let rel_elevation = 2.0 * curve.interpolate(el / 2.0 + 0.5) - 1.0;
                let mut elevation = rel_elevation as f32 * h_max;
                if h_step > 0.0 {
                    elevation = (elevation / h_step).round() * h_step
                }
                *v += normal * elevation;

                let lat = normal.y.asin().to_degrees().abs();
                let lat_factor = lat / 90.0;
                let alt_factor = (elevation / h_max).max(0.0);
                let temperature = 1.0 - (lat_factor + alt_factor).clamp(0.0, 1.0);

                NodeData {
                    position: *v,
                    elevation,
                    is_water: elevation < 0.0,
                    temperature,
                    precipitation: cl,
                }
            })
            .collect()
    }

    fn generate_colors(&self, nodes: &[NodeData]) -> ColorArray {
        let mut colors = ColorArray::new();
        for node in nodes {
            let color = Color::rgb(node.temperature, 1.0 - node.temperature, 0.0);
            colors.push(color);
        }

        colors
    }
}

fn create_noise(noise_type: &str, octaves: usize) -> Box<dyn NoiseFn<[f64; 3]>> {
    match noise_type {
        "basic" => Box::new(BasicMulti::new().set_octaves(octaves)),
        "billow" => Box::new(Billow::new().set_octaves(octaves)),
        "fbm" => Box::new(Fbm::new().set_octaves(octaves)),
        "hybrid" => Box::new(HybridMulti::new().set_octaves(octaves)),
        "ridged" => Box::new(RidgedMulti::new().set_octaves(octaves)),
        "open-simplex" => Box::new(OpenSimplex::new()),
        "super-simplex" => Box::new(SuperSimplex::new()),
        "perlin" => Box::new(Perlin::new()),
        _ => panic!("Unknown noise type {}", noise_type),
    }
}
