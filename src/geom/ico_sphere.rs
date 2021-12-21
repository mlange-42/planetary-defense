use std::collections::HashMap;
use std::f32::consts::PI;

use gdnative::api::{ArrayMesh, Mesh};
use gdnative::core_types::{Int32Array, Vector3Array};
use gdnative::prelude::*;

const DEG2RAD: f32 = PI / 180.0;

#[derive(NativeClass, Copy, Clone, Default)]
#[user_data(Aether<IcoSphere>)]
#[inherit(Object)]
pub struct IcoSphere;

#[methods]
impl IcoSphere {
    fn new(_owner: &Object) -> Self {
        Self {}
    }

    #[export]
    pub fn create_ico_sphere(
        &self,
        _owner: &Object,
        radius: f32,
        subdivisions: u32,
    ) -> (Vec<Vec3>, Vec<(usize, usize, usize)>) {
        IcoSphereGenerator::new(radius, subdivisions).generate()
    }

    #[export]
    pub fn to_mesh(
        &self,
        _owner: &Object,
        vertices: Vec<Vec3>,
        faces: Vec<(usize, usize, usize)>,
    ) -> Ref<ArrayMesh, Unique> {
        let mut verts = Vector3Array::new();
        let mut indices = Int32Array::new();
        let mut normals = Vector3Array::new();

        for v in vertices {
            let vec = Vector3::new(v.0, v.1, v.2);
            verts.push(vec);
            normals.push(vec.normalize());
        }

        for face in faces {
            indices.push(face.0 as i32);
            indices.push(face.1 as i32);
            indices.push(face.2 as i32);
        }

        let arr = VariantArray::new_shared();
        unsafe {
            #[allow(deprecated)]
            arr.resize(Mesh::ARRAY_MAX as i32);
        }
        arr.set(Mesh::ARRAY_INDEX as i32, indices);
        arr.set(Mesh::ARRAY_VERTEX as i32, verts);
        arr.set(Mesh::ARRAY_NORMAL as i32, normals);

        let mesh = ArrayMesh::new();
        mesh.add_surface_from_arrays(
            Mesh::PRIMITIVE_TRIANGLES,
            arr,
            VariantArray::new_shared(),
            97280,
        );

        mesh
    }
}

pub struct IcoSphereGenerator {
    radius: f32,
    subdivisions: u32,
    vertices: Vec<Vec3>,
}

impl IcoSphereGenerator {
    fn new(radius: f32, subdivisions: u32) -> Self {
        Self {
            radius,
            subdivisions,
            vertices: Default::default(),
        }
    }

    fn generate(mut self) -> (Vec<Vec3>, Vec<(usize, usize, usize)>) {
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
        let middle = (0.5 * (self.vertices[point_1] + self.vertices[point_2])).normalized();

        self.vertices.push(middle);
        let index = self.vertices.len() - 1;
        cache.insert(key, index);
        index
    }
}

fn ll_to_xyz(lon: f32, lat: f32) -> Vec3 {
    let lon = lon * DEG2RAD;
    let lat = lat * DEG2RAD;
    let cos_lat = lat.cos();
    let sin_lat = lat.sin();
    let cos_lon = lon.cos();
    let sin_lon = lon.sin();

    let x = cos_lat * cos_lon;
    let y = sin_lat;
    let z = cos_lat * sin_lon;

    Vec3(x, y, z)
}

#[derive(Copy, Clone, Debug, PartialEq, FromVariant, ToVariant)]
pub struct Vec3(pub f32, pub f32, pub f32);

impl Vec3 {
    fn normalized(self) -> Self {
        let len = self.length();
        Self(self.0 / len, self.1 / len, self.2 / len)
    }
    fn length(self) -> f32 {
        self.length_sq().sqrt()
    }

    fn length_sq(self) -> f32 {
        self.0 * self.0 + self.1 * self.1 + self.2 * self.2
    }
}

impl std::ops::Add for Vec3 {
    type Output = Vec3;
    fn add(self, rhs: Self) -> Self::Output {
        Self(self.0 + rhs.0, self.1 + rhs.1, self.2 + rhs.2)
    }
}

impl std::ops::Mul<f32> for Vec3 {
    type Output = Vec3;
    fn mul(self, rhs: f32) -> Self::Output {
        Self(self.0 * rhs, self.1 * rhs, self.2 * rhs)
    }
}

impl std::ops::Mul<Vec3> for f32 {
    type Output = Vec3;
    fn mul(self, rhs: Vec3) -> Self::Output {
        Vec3(self * rhs.0, self * rhs.1, self * rhs.2)
    }
}

impl std::ops::MulAssign<f32> for Vec3 {
    fn mul_assign(&mut self, rhs: f32) {
        *self = Self(self.0 * rhs, self.1 * rhs, self.2 * rhs)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const DELTA: f32 = 0.0000001;

    #[test]
    fn test_ll_to_xyz() {
        let xyz = ll_to_xyz(0.0, 90.0);
        assert!((xyz.0 - 0.0).abs() < DELTA);
        assert!((xyz.1 - 1.0).abs() < DELTA);
        assert!((xyz.2 - 0.0).abs() < DELTA);

        let xyz = ll_to_xyz(0.0, 0.0);
        assert!((xyz.0 - 1.0).abs() < DELTA);
        assert!((xyz.1 - 0.0).abs() < DELTA);
        assert!((xyz.2 - 0.0).abs() < DELTA);

        let xyz = ll_to_xyz(90.0, 0.0);
        assert!((xyz.0 - 0.0).abs() < DELTA);
        assert!((xyz.1 - 0.0).abs() < DELTA);
        assert!((xyz.2 - 1.0).abs() < DELTA);
    }

    #[test]
    fn test_vec3() {
        assert_eq!(
            Vec3(1.0, 2.0, 3.0) + Vec3(3.0, 2.0, 1.0),
            Vec3(4.0, 4.0, 4.0)
        );

        assert_eq!(Vec3(1.0, 2.0, 3.0) * 2.0, Vec3(2.0, 4.0, 6.0));
        assert_eq!(2.0 * Vec3(1.0, 2.0, 3.0), Vec3(2.0, 4.0, 6.0));

        let mut vec = Vec3(1.0, 2.0, 3.0);
        vec *= 2.0;
        assert_eq!(vec, Vec3(2.0, 4.0, 6.0));

        assert!((Vec3(1.0, 1.0, 1.0).normalized().length() - 1.0).abs() < DELTA);
    }

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
