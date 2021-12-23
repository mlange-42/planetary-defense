use gdnative::api::Curve;
use gdnative::prelude::*;
use std::collections::HashMap;

use noise::{
    BasicMulti, Billow, Fbm, HybridMulti, MultiFractal, NoiseFn, OpenSimplex, Perlin, RidgedMulti,
    Seedable, SuperSimplex,
};

use crate::geom::godot_util::{to_collision_shape, to_mesh};
use crate::geom::ico_sphere::IcoSphereGenerator;
use crate::geom::planet::data::{NodeData, NodeNeighbors, PlanetData, DIST_FACTOR};

const LU_DESERT: u32 = 0;
const LU_GLACIER: u32 = 1;
const LU_TUNDRA: u32 = 2;
const LU_TAIGA: u32 = 3;
const LU_STEPPE: u32 = 4;
const LU_TEMPERATE_FOREST: u32 = 5;
const LU_SUBTROPICAL_FOREST: u32 = 6;
const LU_TROPICAL_FOREST: u32 = 7;

lazy_static! {
    static ref LU_COLORS: HashMap<u32, Color> = {
        let mut m = HashMap::new();
        m.insert(LU_DESERT, Color::rgb(1.0, 1.0, 0.3));
        m.insert(LU_GLACIER, Color::rgb(1.0, 1.0, 1.0));
        m.insert(LU_TUNDRA, Color::rgb(0.0, 0.9, 0.3));
        m.insert(LU_TAIGA, Color::rgb(0.0, 0.5, 0.3));
        m.insert(LU_STEPPE, Color::rgb(0.5, 0.7, 0.2));
        m.insert(LU_TEMPERATE_FOREST, Color::rgb(0.2, 0.6, 0.0));
        m.insert(LU_SUBTROPICAL_FOREST, Color::rgb(0.0, 1.0, 0.0));
        m.insert(LU_TROPICAL_FOREST, Color::rgb(0.0, 0.5, 0.0));
        m
    };
    static ref LU_MATRIX: Vec<Vec<u32>> = str_to_vec(
        r#"
    11111120000000000000
    11111120000000000000
    11111120000000000000
    11111120000000000000
    11111120000000000000
    11111120000000000000
    11111120000000000000
    11111120000000000000
    11111124444444444444
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777
    11111123335555567777"#
    );
}

struct PlanetGeneratorParams {
    radius: f32,
    subdivisions: u32,
    terrain_max_height: f32,
    terrain_height_step: f32,
    terrain_noise_type: String,
    terrain_noise_period: f32,
    terrain_noise_octaves: usize,
    terrain_noise_seed: u32,
    terrain_curve: Ref<Curve>,
    climate_noise_type: String,
    climate_noise_period: f32,
    climate_noise_octaves: usize,
    climate_noise_seed: u32,
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
        terrain_noise_seed: u32,
        terrain_curve: Ref<Curve>,
        climate_noise_type: String,
        climate_noise_period: f32,
        climate_noise_octaves: usize,
        climate_noise_seed: u32,
    ) {
        self.params = Some(PlanetGeneratorParams {
            radius,
            subdivisions,
            terrain_max_height,
            terrain_height_step,
            terrain_noise_type,
            terrain_noise_period,
            terrain_noise_octaves,
            terrain_noise_seed,
            terrain_curve,
            climate_noise_type,
            climate_noise_period,
            climate_noise_octaves,
            climate_noise_seed,
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

        let noise = create_noise(
            &params.terrain_noise_type,
            params.terrain_noise_seed,
            params.terrain_noise_octaves,
        );
        let climate_noise = create_noise(
            &params.climate_noise_type,
            params.climate_noise_seed,
            params.climate_noise_octaves,
        );

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
                let v_node = if elevation < 0.0 {
                    *v
                } else {
                    *v + normal * elevation
                };
                *v += normal * elevation;

                let lat = normal.y.asin().to_degrees().abs();
                let lat_factor = lat / 90.0;
                let alt_factor = (elevation / h_max).max(0.0);
                let temperature = 1.0 - (lat_factor + alt_factor).clamp(0.0, 1.0);

                let m_index = (cl.clamp(0.0, 0.99999) * LU_MATRIX.len() as f32) as usize;
                let t_index =
                    (temperature.clamp(0.0, 0.99999) * LU_MATRIX[0].len() as f32) as usize;

                let land_use = LU_MATRIX[m_index][t_index];

                /*let land_use = if temperature < 0.3 {
                    LU_GLACIER
                } else if temperature < 0.35 {
                    LU_TUNDRA
                } else if cl < 0.4 {
                    LU_DESERT
                } else if cl < 0.45 {
                    LU_STEPPE
                } else if temperature < 0.5 {
                    LU_TAIGA
                } else if temperature < 0.75 {
                    LU_TEMPERATE_FOREST
                } else if temperature < 0.80 {
                    LU_SUBTROPICAL_FOREST
                } else {
                    LU_TROPICAL_FOREST
                };*/

                NodeData {
                    position: v_node,
                    elevation,
                    is_water: elevation <= 0.0,
                    temperature,
                    precipitation: cl,
                    land_use,
                }
            })
            .collect()
    }

    fn generate_colors(&self, nodes: &[NodeData]) -> ColorArray {
        let mut colors = ColorArray::new();
        for node in nodes {
            let color = LU_COLORS[&node.land_use];
            colors.push(color);
        }

        colors
    }
}

fn create_noise(noise_type: &str, seed: u32, octaves: usize) -> Box<dyn NoiseFn<[f64; 3]>> {
    match noise_type {
        "basic" => Box::new(BasicMulti::new().set_seed(seed).set_octaves(octaves)),
        "billow" => Box::new(Billow::new().set_seed(seed).set_octaves(octaves)),
        "fbm" => Box::new(Fbm::new().set_seed(seed).set_octaves(octaves)),
        "hybrid" => Box::new(HybridMulti::new().set_seed(seed).set_octaves(octaves)),
        "ridged" => Box::new(RidgedMulti::new().set_seed(seed).set_octaves(octaves)),
        "open-simplex" => Box::new(OpenSimplex::new().set_seed(seed)),
        "super-simplex" => Box::new(SuperSimplex::new().set_seed(seed)),
        "perlin" => Box::new(Perlin::new().set_seed(seed)),
        _ => panic!("Unknown noise type {}", noise_type),
    }
}

fn str_to_vec(text: &str) -> Vec<Vec<u32>> {
    text.split('\n')
        .filter_map(|row| {
            if row.is_empty() || row == " " {
                None
            } else {
                Some(
                    row.split("")
                        .filter_map(|c| {
                            if c.is_empty() || c == " " {
                                None
                            } else {
                                Some(c.parse().unwrap())
                            }
                        })
                        .collect(),
                )
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_lu_matrix() {
        for row in LU_MATRIX.iter() {
            println!("{:?}", row);
        }
    }
}
