use gdnative::core_types::Vector3;

pub fn ll_to_xyz(lon: f32, lat: f32) -> Vector3 {
    let r = lat.to_radians().cos();
    let x = r * lon.to_radians().cos();
    let y = lat.to_radians().sin();
    let z = r * lon.to_radians().sin();

    Vector3::new(x, y, z)
}

pub fn calc_normals(vertices: &[Vector3], faces: &[(usize, usize, usize)]) -> Vec<Vector3> {
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
