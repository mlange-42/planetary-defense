use gdnative::prelude::*;

pub fn ll_to_xyz(lon: f32, lat: f32) -> Vector3 {
    let r = lat.to_radians().cos();
    let x = r * lon.to_radians().cos();
    let y = lat.to_radians().sin();
    let z = r * lon.to_radians().sin();

    Vector3::new(x, y, z)
}

pub fn calc_normals_tuple(vertices: &[Vector3], faces: &[(usize, usize, usize)]) -> Vec<Vector3> {
    let mut result: Vec<Vector3> = vec![Default::default(); vertices.len()];

    for (id1, id2, id3) in faces {
        let norm = calc_face_normal(vertices[*id1], vertices[*id2], vertices[*id3]);
        result[*id1] += norm;
        result[*id2] += norm;
        result[*id3] += norm;
    }

    for normal in result.iter_mut() {
        *normal = normal.normalize();
    }

    result
}

pub fn calc_normals_godot(vertices: &Vector3Array, faces: &Int32Array) -> Vector3Array {
    let mut result: Vector3Array = (0..vertices.len()).map(|_| Vector3::zero()).collect();

    for base in 0..(faces.len() / 3) {
        let (i1, i2, i3) = (
            faces.get(base * 3),
            faces.get(base * 3 + 1),
            faces.get(base * 3 + 2),
        );
        let norm = calc_face_normal(vertices.get(i1), vertices.get(i2), vertices.get(i3));
        result.set(i1, result.get(i1) + norm);
        result.set(i2, result.get(i2) + norm);
        result.set(i3, result.get(i3) + norm);
    }

    for i in 0..result.len() {
        result.set(i, result.get(i).normalize());
    }

    result
}

pub fn calc_face_normal(v1: Vector3, v2: Vector3, v3: Vector3) -> Vector3 {
    let u = v2 - v1;
    let v = v3 - v1;

    v.cross(u).normalize()
}

#[cfg(test)]
mod tests {
    use super::*;

    const DELTA: f32 = 0.0000001;

    #[test]
    fn test_ll_to_xyz() {
        let xyz = ll_to_xyz(0.0, 90.0);
        assert!((xyz.x - 0.0).abs() < DELTA);
        assert!((xyz.y - 1.0).abs() < DELTA);
        assert!((xyz.z - 0.0).abs() < DELTA);

        let xyz = ll_to_xyz(0.0, 0.0);
        assert!((xyz.x - 1.0).abs() < DELTA);
        assert!((xyz.y - 0.0).abs() < DELTA);
        assert!((xyz.z - 0.0).abs() < DELTA);

        let xyz = ll_to_xyz(90.0, 0.0);
        assert!((xyz.x - 0.0).abs() < DELTA);
        assert!((xyz.y - 0.0).abs() < DELTA);
        assert!((xyz.z - 1.0).abs() < DELTA);
    }
}
