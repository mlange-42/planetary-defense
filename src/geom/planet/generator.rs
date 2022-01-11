use gdnative::api::Curve;
use gdnative::prelude::*;
use std::cmp::Ordering::Equal;
use std::f32::consts::PI;

use noise::{
    BasicMulti, Billow, Fbm, HybridMulti, MultiFractal, NoiseFn, OpenSimplex, Perlin, RidgedMulti,
    Seedable, SuperSimplex,
};

use crate::geom::godot_util::{to_collision_shape, to_sub_mesh};
use crate::geom::ico_sphere::IcoSphereGenerator;
use crate::geom::planet::data::{
    NodeData, NodeNeighbors, PlanetData, PlanetProperties, DIST_FACTOR,
};
use crate::geom::planet::serialize::from_csv;
use crate::geom::util::xyz_to_ll;

#[allow(dead_code)]
const VEG_DESERT: u32 = 0;
#[allow(dead_code)]
const VEG_GLACIER: u32 = 1;
#[allow(dead_code)]
const VEG_TUNDRA: u32 = 2;
#[allow(dead_code)]
const VEG_TAIGA: u32 = 3;
#[allow(dead_code)]
const VEG_STEPPE: u32 = 4;
#[allow(dead_code)]
const VEG_TEMPERATE_FOREST: u32 = 5;
#[allow(dead_code)]
const VEG_SUBTROPICAL_FOREST: u32 = 6;
#[allow(dead_code)]
const VEG_TROPICAL_FOREST: u32 = 7;
#[allow(dead_code)]
const VEG_WATER: u32 = 8;
#[allow(dead_code)]
const VEG_CLIFFS: u32 = 9;

lazy_static! {
    static ref VEG_COLORS: [Color; 10] = [
        Color::rgb(1.0, 1.0, 0.3),
        Color::rgb(1.0, 1.0, 1.0),
        Color::rgb(0.0, 0.9, 0.3),
        Color::rgb(0.0, 0.5, 0.3),
        Color::rgb(0.5, 0.7, 0.2),
        Color::rgb(0.2, 0.6, 0.0),
        Color::rgb(0.0, 1.0, 0.0),
        Color::rgb(0.0, 0.5, 0.0),
        Color::rgb(1.0, 1.0, 0.5),
        Color::rgb(0.5, 0.5, 0.5),
    ];
    static ref VEG_MATRIX: Vec<Vec<u32>> = str_to_vec(
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
    temperature_curve: Ref<Curve>,
    precipitation_curve: Ref<Curve>,
    atlas_size: (u32, u32),
    atlas_margins: (f32, f32),
    contour_step: f32,
    min_slope_cliffs: f32,
    min_elevation_cliffs: f32,
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
        temperature_curve: Ref<Curve>,
        precipitation_curve: Ref<Curve>,
        atlas_size: (u32, u32),
        atlas_margins: (f32, f32),
        contour_step: f32,
        min_slope_cliffs: f32,
        min_elevation_cliffs: f32,
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
            temperature_curve,
            precipitation_curve,
            atlas_size,
            atlas_margins,
            contour_step,
            min_slope_cliffs,
            min_elevation_cliffs,
        })
    }

    #[export]
    fn from_csv(&self, _owner: &Reference, path: String) -> VariantArray<Unique> {
        let par = self.params.as_ref().unwrap();

        let data = from_csv(&path).unwrap();
        let colors = self.generate_colors(&data.nodes);

        let mesh = to_sub_mesh(
            &data.nodes,
            &data.vertices,
            &data.faces,
            Some(colors),
            par.atlas_size,
            par.atlas_margins,
            par.contour_step,
        );
        let shape = to_collision_shape(&data.nodes, &data.faces);

        let arr = VariantArray::new();
        arr.push(data.emplace());
        arr.push(mesh);
        arr.push(shape);

        arr
    }

    #[export]
    fn generate(&self, _owner: &Reference) -> VariantArray<Unique> {
        let params = self.params.as_ref().unwrap();

        let (mut vertices, faces) =
            IcoSphereGenerator::new(params.radius, params.subdivisions).generate();

        let mut neighbors: Vec<_> = vertices.iter().map(|_| NodeNeighbors::default()).collect();

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

        let nodes = self.generate_terrain(&mut vertices, &neighbors);
        let colors = self.generate_colors(&nodes);

        let radius = self.params.as_ref().unwrap().radius;
        let cell_area = (4.0 * PI * radius * radius) / (nodes.len() as f32);
        let cell_radius = (cell_area / PI).sqrt();

        let props = PlanetProperties {
            radius,
            cell_radius,
            max_elevation: self.params.as_ref().unwrap().terrain_max_height,
        };

        let data = PlanetData::new(props, nodes, vertices, neighbors, faces);

        let mesh = to_sub_mesh(
            &data.nodes,
            &data.vertices,
            &data.faces,
            Some(colors),
            params.atlas_size,
            params.atlas_margins,
            params.contour_step,
        );
        let shape = to_collision_shape(&data.nodes, &data.faces);

        let arr = VariantArray::new();
        arr.push(data.emplace());
        arr.push(mesh);
        arr.push(shape);

        arr
    }

    fn generate_terrain(
        &self,
        vertices: &mut [Vector3],
        neighbors: &[NodeNeighbors],
    ) -> Vec<NodeData> {
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
        let height_curve = unsafe { &params.terrain_curve.clone().assume_unique() };
        let temperature_curve = unsafe { &params.temperature_curve.clone().assume_unique() };
        let precipitation_curve = unsafe { &params.precipitation_curve.clone().assume_unique() };

        let scale = 1.0 / (params.terrain_noise_period * params.radius);
        let climate_scale = 1.0 / (params.climate_noise_period * params.radius);

        let mut nodes: Vec<_> = vertices
            .iter_mut()
            .map(|v| {
                let normal = v.normalize();
                let el = noise.get([
                    (scale * v.x) as f64,
                    (scale * v.y) as f64,
                    (scale * v.z) as f64,
                ]);
                let rel_elevation = 2.0 * height_curve.interpolate(el / 2.0 + 0.5) - 1.0;

                let precipitation = precipitation_curve.interpolate(
                    climate_noise.get([
                        (climate_scale * v.x) as f64,
                        (climate_scale * v.y) as f64,
                        (climate_scale * v.z) as f64,
                    ]) / 2.0
                        + 0.5,
                ) as f32;

                let mut elevation = rel_elevation as f32 * h_max;
                stepify(&mut elevation, h_step, true);

                let v_node = if elevation < 0.0 {
                    *v
                } else {
                    *v + normal * elevation
                };
                *v += normal * elevation;

                let is_water = elevation <= 0.0;

                let lonlat = xyz_to_ll(normal);
                let lat = lonlat.y.abs();
                let lat_factor = lat / 90.0;
                let alt_factor = (elevation / h_max).max(0.0);
                let temperature = temperature_curve
                    .interpolate(1.0 - (lat_factor + alt_factor).clamp(0.0, 1.0) as f64)
                    as f32;

                NodeData {
                    position: v_node,
                    elevation,
                    is_water,
                    is_port: false,
                    is_occupied: false,
                    temperature,
                    precipitation,
                    vegetation_type: VEG_GLACIER,
                }
            })
            .collect();

        let vegetation: Vec<_> = nodes
            .iter()
            .enumerate()
            .map(|(i, node)| {
                let m_index =
                    (node.precipitation.clamp(0.0, 0.99999) * VEG_MATRIX.len() as f32) as usize;
                let t_index =
                    (node.temperature.clamp(0.0, 0.99999) * VEG_MATRIX[0].len() as f32) as usize;

                let max_slope = neighbors[i]
                    .neighbors
                    .iter()
                    .map(|idx| {
                        let other = &nodes[*idx];
                        if other.is_water {
                            0.0
                        } else {
                            node.elevation - other.elevation
                        }
                    })
                    .max_by(|a, b| a.partial_cmp(b).unwrap_or(Equal))
                    .unwrap();

                let mut vegetation = if node.is_water {
                    VEG_WATER
                } else {
                    VEG_MATRIX[m_index][t_index]
                };

                if vegetation != VEG_GLACIER
                    && (max_slope > params.min_slope_cliffs
                        || node.elevation > params.min_elevation_cliffs)
                {
                    vegetation = VEG_CLIFFS;
                }

                vegetation
            })
            .collect();

        for (node, veg) in nodes.iter_mut().zip(vegetation) {
            node.vegetation_type = veg;
        }

        nodes
    }

    fn generate_colors(&self, nodes: &[NodeData]) -> ColorArray {
        let mut colors = ColorArray::new();
        for node in nodes {
            let color = VEG_COLORS[node.vegetation_type as usize];
            colors.push(color);
        }

        colors
    }
}

fn stepify(value: &mut f32, step: f32, exclude_zero: bool) {
    if step <= 0.0 {
        return;
    }
    let temp = (*value / step).round() * step;
    if exclude_zero && temp.abs() < step {
        *value = if *value > 0.0 { step } else { -step };
    } else {
        *value = temp;
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
    fn test_veg_matrix() {
        for row in VEG_MATRIX.iter() {
            println!("{:?}", row);
        }
    }
}
