use euclid::Trig;
use gdnative::api::{ArrayMesh, ConcavePolygonShape, Mesh};
use gdnative::core_types::{Int32Array, Vector3Array};
use gdnative::prelude::*;

use crate::geom::util::{calc_normals_godot, calc_normals_tuple};
use crate::NodeData;

pub fn to_collision_shape(
    nodes: &[NodeData],
    faces: &[(usize, usize, usize)],
) -> Ref<ConcavePolygonShape, Unique> {
    let mut coll_faces = Vector3Array::new();

    for face in faces {
        coll_faces.push(nodes[face.0].position);
        coll_faces.push(nodes[face.1].position);
        coll_faces.push(nodes[face.2].position);
    }

    let shape = ConcavePolygonShape::new();
    shape.set_faces(coll_faces);

    shape
}

pub fn to_sub_mesh(
    nodes: &[NodeData],
    vertices: &[Vector3],
    faces: &[(usize, usize, usize)],
    cols: Option<ColorArray>,
    atlas_size: u32,
    atlas_margins: f32,
) -> Ref<ArrayMesh, Unique> {
    let uv_scale = 1.0 / atlas_size as f32;

    let to_tile = |tp: u32| (tp % atlas_size, tp / atlas_size);

    let mut verts = Vector3Array::new();
    let mut indices = Int32Array::new();
    let mut colors = ColorArray::new();
    let mut uvs = Vector2Array::new();

    let mut vert_faces = vec![vec![]; vertices.len()];

    for (i, face) in faces.iter().enumerate() {
        vert_faces[face.0].push(i);
        vert_faces[face.1].push(i);
        vert_faces[face.2].push(i);
    }

    for (v, (vert, node)) in vertices.iter().zip(nodes).enumerate() {
        let tex = node.vegetation_type;
        let ele = node.elevation;

        verts.push(*vert);
        let (x, y) = to_tile(tex);
        uvs.push(Vector2::new(
            (x as f32 + 0.5) * uv_scale,
            (y as f32 + 0.5) * uv_scale,
        ));

        let p0 = face_centroid(faces[vert_faces[v][0]], vertices);

        let origin = *vert;
        let normal = vert.normalize();

        let e1 = (project_to_plane(p0, origin, normal) - origin).normalize();
        let e2 = normal.cross(e1);

        let mut outer: Vec<_> = vert_faces[v]
            .iter()
            .map(|f| {
                let face = faces[*f];
                let centroid = face_centroid(faces[*f], vertices);
                let indices = if v == face.0 {
                    (face.1, face.2)
                } else if v == face.1 {
                    (face.0, face.2)
                } else {
                    (face.0, face.1)
                };
                (centroid, angle_on_plane(centroid, origin, e1, e2), indices)
            })
            .collect();

        outer.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap());

        let start_index = verts.len();
        let count = outer.len() as i32;

        for i in 0..count {
            let p0 = start_index - 1;
            let p1 = start_index + (2 * i as i32 + 1) % (2 * count);
            let p2 = start_index + 2 * i as i32;

            let idx1 = i as usize;
            let idx2 = (i + 1) as usize % count as usize;

            let fn1 = outer[idx1].2;
            let fn2 = outer[idx2].2;
            let common_node = if fn1.0 == fn2.0 || fn1.0 == fn2.1 {
                fn1.0
            } else {
                fn1.1
            };

            let is_contour = ((nodes[common_node].elevation * 10.0) as u32) < ((ele * 10.0) as u32);
            let (uv_x_off, uv_off_flip) = if is_contour { (0, 1.0) } else { (1, -1.0) };

            verts.push(outer[idx1].0);
            verts.push(outer[idx2].0);

            indices.push(p0);

            indices.push(p1);
            indices.push(p2);

            uvs.push(Vector2::new(
                (x + uv_x_off) as f32 * uv_scale + uv_off_flip * atlas_margins,
                y as f32 * uv_scale + atlas_margins,
            ));

            uvs.push(Vector2::new(
                (x + uv_x_off) as f32 * uv_scale + uv_off_flip * atlas_margins,
                (y + 1) as f32 * uv_scale - atlas_margins,
            ));
        }

        if let Some(cols) = &cols {
            let col = cols.get(v as i32);
            for _ in 0..(2 * outer.len() + 1) {
                colors.push(col);
            }
        }
    }

    let normals = calc_normals_godot(&verts, &indices);

    let arr = VariantArray::new_shared();
    unsafe {
        #[allow(deprecated)]
        arr.resize(Mesh::ARRAY_MAX as i32);
    }

    arr.set(Mesh::ARRAY_INDEX as i32, indices);
    arr.set(Mesh::ARRAY_VERTEX as i32, verts);
    arr.set(Mesh::ARRAY_NORMAL as i32, normals);
    arr.set(Mesh::ARRAY_TEX_UV as i32, uvs);

    if let Some(_cols) = &cols {
        arr.set(Mesh::ARRAY_COLOR as i32, colors);
    }

    let mesh = ArrayMesh::new();
    mesh.add_surface_from_arrays(
        Mesh::PRIMITIVE_TRIANGLES,
        arr,
        VariantArray::new_shared(),
        97280,
    );

    mesh
}

fn project_to_plane(vec: Vector3, origin: Vector3, normal: Vector3) -> Vector3 {
    let dist = (vec - origin).dot(normal);
    vec - (normal * dist)
}

fn angle_on_plane(vec: Vector3, origin: Vector3, e1: Vector3, e2: Vector3) -> f32 {
    let v = vec - origin;
    let x = e1.dot(v);
    let y = e2.dot(v);
    Trig::fast_atan2(y, x)
}

fn face_centroid(face: (usize, usize, usize), vertices: &[Vector3]) -> Vector3 {
    (vertices[face.0] + vertices[face.1] + vertices[face.2]) / 3.0
}

#[allow(dead_code)]
pub fn to_mesh(
    vertices: &[Vector3],
    faces: &[(usize, usize, usize)],
    colors: Option<ColorArray>,
) -> Ref<ArrayMesh, Unique> {
    let mut verts = Vector3Array::new();
    let mut indices = Int32Array::new();
    let mut normals = Vector3Array::new();

    let norm = calc_normals_tuple(vertices, faces);

    for (v, n) in vertices.iter().zip(norm) {
        verts.push(*v);
        normals.push(n);
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

    if let Some(colors) = colors {
        arr.set(Mesh::ARRAY_COLOR as i32, colors);
    }

    let mesh = ArrayMesh::new();
    mesh.add_surface_from_arrays(
        Mesh::PRIMITIVE_TRIANGLES,
        arr,
        VariantArray::new_shared(),
        97280,
    );

    mesh
}
