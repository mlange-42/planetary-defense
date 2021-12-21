use super::types::Vec3;
use std::f32::consts::PI;

const DEG2RAD: f32 = PI / 180.0;

pub fn ll_to_xyz(lon: f32, lat: f32) -> Vec3 {
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

pub fn calc_normals(vertices: &[Vec3], faces: &[(usize, usize, usize)]) -> Vec<Vec3> {
    let mut result: Vec<Vec3> = vec![Default::default(); vertices.len()];

    for (id1, id2, id3) in faces {
        let norm = calc_face_normal(vertices[*id1], vertices[*id2], vertices[*id3]);
        result[*id1] += norm;
        result[*id2] += norm;
        result[*id3] += norm;
    }

    for normal in result.iter_mut() {
        *normal = normal.normalized();
    }

    result
}

pub fn calc_face_normal(v1: Vec3, v2: Vec3, v3: Vec3) -> Vec3 {
    let u = v2 - v1;
    let v = v3 - v1;

    v.cross(u).normalized()
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
}
