use gdnative::prelude::{FromVariant, ToVariant};
use std::ops::{Add, Mul};

#[derive(Copy, Clone, Debug, Default, PartialEq, FromVariant, ToVariant)]
pub struct Vec3(pub f32, pub f32, pub f32);

impl Vec3 {
    pub fn normalized(self) -> Self {
        let len = self.length();
        Self(self.0 / len, self.1 / len, self.2 / len)
    }

    pub fn cross(self, rhs: Self) -> Self {
        Self(
            self.1 * rhs.2 - self.2 * rhs.1,
            self.2 * rhs.0 - self.0 * rhs.2,
            self.0 * rhs.1 - self.1 * rhs.0,
        )
    }

    pub fn length(self) -> f32 {
        self.length_sq().sqrt()
    }

    pub fn length_sq(self) -> f32 {
        self.0 * self.0 + self.1 * self.1 + self.2 * self.2
    }
}

impl std::ops::Add for Vec3 {
    type Output = Vec3;
    fn add(self, rhs: Self) -> Self::Output {
        Self(self.0 + rhs.0, self.1 + rhs.1, self.2 + rhs.2)
    }
}

impl std::ops::AddAssign<Vec3> for Vec3 {
    fn add_assign(&mut self, rhs: Vec3) {
        *self = self.add(rhs);
    }
}

impl std::ops::Sub for Vec3 {
    type Output = Vec3;
    fn sub(self, rhs: Self) -> Self::Output {
        Self(self.0 - rhs.0, self.1 - rhs.1, self.2 - rhs.2)
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
        *self = self.mul(rhs)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const DELTA: f32 = 0.0000001;

    #[test]
    fn test_vec3_ops() {
        assert_eq!(
            Vec3(1.0, 2.0, 3.0) + Vec3(3.0, 2.0, 1.0),
            Vec3(4.0, 4.0, 4.0)
        );

        assert_eq!(Vec3(1.0, 2.0, 3.0) * 2.0, Vec3(2.0, 4.0, 6.0));
        assert_eq!(2.0 * Vec3(1.0, 2.0, 3.0), Vec3(2.0, 4.0, 6.0));

        let mut vec = Vec3(1.0, 2.0, 3.0);
        vec *= 2.0;
        assert_eq!(vec, Vec3(2.0, 4.0, 6.0));
    }

    #[test]
    fn test_vec3_norm() {
        assert!((Vec3(1.0, 1.0, 1.0).normalized().length() - 1.0).abs() < DELTA);
    }

    #[test]
    fn test_vec3_cross() {
        assert_eq!(
            Vec3(1.0, 0.0, 0.0).cross(Vec3(0.0, 1.0, 0.0)),
            Vec3(0.0, 0.0, 1.0)
        );
    }
}
