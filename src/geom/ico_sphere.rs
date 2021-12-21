use std::collections::HashMap;

use gdnative::api::ArrayMesh;
use gdnative::prelude::*;

use crate::geom::{godot_util::to_mesh, util::ll_to_xyz};

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct IcoSphere;

#[methods]
impl IcoSphere {
    fn new(_owner: &Reference) -> Self {
        Self {}
    }

    #[export]
    pub fn create_ico_sphere(
        &self,
        _owner: &Reference,
        radius: f32,
        subdivisions: u32,
    ) -> (Vec<Vector3>, Vec<(usize, usize, usize)>) {
        IcoSphereGenerator::new(radius, subdivisions).generate()
    }

    #[export]
    pub fn to_mesh(
        &self,
        _owner: &Reference,
        vertices: Vec<Vector3>,
        faces: Vec<(usize, usize, usize)>,
    ) -> Ref<ArrayMesh, Unique> {
        to_mesh(&vertices, &faces)
    }
}

pub struct IcoSphereGenerator {
    radius: f32,
    subdivisions: u32,
    vertices: Vec<Vector3>,
}

impl IcoSphereGenerator {
    pub(crate) fn new(radius: f32, subdivisions: u32) -> Self {
        Self {
            radius,
            subdivisions,
            vertices: Default::default(),
        }
    }

    pub(crate) fn generate(mut self) -> (Vec<Vector3>, Vec<(usize, usize, usize)>) {
        let mut cache: HashMap<(usize, usize), usize> = HashMap::new();

        self.vertices.push(ll_to_xyz(0.0, -58.5));
        self.vertices.push(ll_to_xyz(0.0, 58.5));
        self.vertices.push(ll_to_xyz(180.0, 58.5));
        self.vertices.push(ll_to_xyz(180.0, -58.5));

        self.vertices.push(ll_to_xyz(90.0, -31.5));
        self.vertices.push(ll_to_xyz(90.0, 31.5));
        self.vertices.push(ll_to_xyz(-90.0, 31.5));
        self.vertices.push(ll_to_xyz(-90.0, -31.5));

        self.vertices.push(ll_to_xyz(-31.5, 0.0));
        self.vertices.push(ll_to_xyz(31.5, 0.0));
        self.vertices.push(ll_to_xyz(148.5, 0.0));
        self.vertices.push(ll_to_xyz(-148.5, 0.0));

        let mut indices = vec![
            (1, 2, 6),
            (1, 5, 2),
            (5, 10, 2),
            (2, 10, 11),
            (2, 11, 6),
            (7, 6, 11),
            (8, 6, 7),
            (8, 1, 6),
            (9, 1, 8),
            (9, 5, 1),
            (9, 4, 5),
            (4, 10, 5),
            (10, 4, 3),
            (10, 3, 11),
            (11, 3, 7),
            (0, 8, 7),
            (0, 9, 8),
            (4, 9, 0),
            (4, 0, 3),
            (3, 0, 7),
        ];

        for _ in 0..self.subdivisions {
            let mut indices_subdiv = vec![(0, 0, 0); indices.len() * 4];
            for (j, tri) in indices.iter().enumerate() {
                let v1 = self.middle_point(tri.0, tri.1, &mut cache);
                let v2 = self.middle_point(tri.1, tri.2, &mut cache);
                let v3 = self.middle_point(tri.2, tri.0, &mut cache);

                indices_subdiv[4 * j] = (tri.0, v1, v3);
                indices_subdiv[4 * j + 1] = (tri.1, v2, v1);
                indices_subdiv[4 * j + 2] = (tri.2, v3, v2);
                indices_subdiv[4 * j + 3] = (v1, v2, v3);
            }

            std::mem::swap(&mut indices, &mut indices_subdiv);
        }

        for v in self.vertices.iter_mut() {
            *v *= self.radius;
        }

        (self.vertices, indices)
    }

    fn middle_point(
        &mut self,
        point_1: usize,
        point_2: usize,
        cache: &mut HashMap<(usize, usize), usize>,
    ) -> usize {
        let (point_1, point_2) = if point_1 < point_2 {
            (point_1, point_2)
        } else {
            (point_2, point_1)
        };
        let key = (point_1, point_2);
        if cache.contains_key(&key) {
            return cache[&key];
        }
        let middle = ((self.vertices[point_1] + self.vertices[point_2]) * 0.5).normalize();

        self.vertices.push(middle);
        let index = self.vertices.len() - 1;
        cache.insert(key, index);
        index
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const DELTA: f32 = 0.0000001;

    #[test]
    fn test_ico_sphere() {
        test_ico_counts(0);
        test_ico_counts(1);
        test_ico_counts(2);
    }

    fn test_ico_counts(subs: usize) {
        let t = 4_usize.pow(subs as u32);
        let (vertices, faces) = IcoSphereGenerator::new(1.0, subs as u32).generate();
        let nf = 20 * t;
        let ne = (3 * nf) / 2;
        assert_eq!(faces.len(), nf);
        assert_eq!(vertices.len(), ne + 2 - nf);

        for v in vertices {
            assert!((v.length() - 1.0).abs() < DELTA)
        }
    }
}
