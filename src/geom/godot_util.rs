use gdnative::api::{ArrayMesh, Mesh};
use gdnative::core_types::{Int32Array, Vector3Array};
use gdnative::prelude::*;

use crate::geom::{types::Vec3, util::calc_normals};

pub fn to_mesh(vertices: Vec<Vec3>, faces: Vec<(usize, usize, usize)>) -> Ref<ArrayMesh, Unique> {
    let mut verts = Vector3Array::new();
    let mut indices = Int32Array::new();
    let mut normals = Vector3Array::new();

    let norm = calc_normals(&vertices, &faces);

    for (v, n) in vertices.iter().zip(norm) {
        verts.push(Vector3::new(v.0, v.1, v.2));
        normals.push(Vector3::new(n.0, n.1, n.2));
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
