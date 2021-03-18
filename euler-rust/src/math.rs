/// General math functions

use rug::{Assign, Integer};
use std::convert::TryFrom;

const MAX_52_BIT: u64 = 4_503_599_627_370_495;

pub struct FibonacciIter {
    f1: Integer,
    f2: Integer,
}

impl Iterator for FibonacciIter {
    type Item = Integer;

    fn next(&mut self) -> Option<Self::Item> {
        let f3 = Integer::from(&self.f1 + &self.f2);
        self.f1.assign(&self.f2);
        self.f2.assign(f3);
        let f = Integer::from(&self.f1);
        Some(f)
    }
}

pub struct Math { }

impl Math {
    // h/t <https://users.rust-lang.org/t/integer-square-root/96>
    #[allow(clippy::cast_possible_truncation)]
    #[allow(clippy::cast_precision_loss)]
    #[allow(clippy::cast_sign_loss)]
    pub fn isqrt_64(n: u64) -> u32 {
        // f64 only has 52-bit mantissa
        if n > MAX_52_BIT {
            panic!("n={} too large", n);
        }
        // sqrt of 52-bit number will fit in u32
        (n as f64).sqrt() as u32
    }

    // h/t <https://users.rust-lang.org/t/integer-square-root/96>
    #[allow(clippy::cast_possible_truncation)]
    #[allow(clippy::cast_precision_loss)]
    #[allow(clippy::cast_sign_loss)]
    pub fn isqrt(n: u32) -> u32 {
        (n as f64).sqrt() as u32
    }

    pub fn factorial(n: u32) -> Integer {
        let mut fact = Integer::new();
        fact.assign(1);
        let mut n0 = n;
        while n0 > 1 {
            fact *= n0;
            n0 -= 1;
        }
        fact
    }

    pub fn nth_triangular(n: usize) -> u32 {
        let tri = n * (n + 1) / 2;
        u32::try_from(tri).unwrap()
    }

    pub fn fibonacci() -> FibonacciIter {
        let f1 = Integer::from(0);
        let f2 = Integer::from(1);
        FibonacciIter { f1, f2 }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_max_n_isqrt_64() {
        let ns = Math::isqrt_64(MAX_52_BIT);
        assert_eq!(67_108_863, ns);
    }

    #[test]
    #[should_panic]
    fn test_big_n_isqrt_64() {
        Math::isqrt_64(MAX_52_BIT + 1);
    }

    #[test]
    fn test_max_n_isqrt() {
        let ns = Math::isqrt(std::u32::MAX);
        assert_eq!(65535, ns);
    }

    #[test]
    fn test_factorial() {
        assert_eq!(3628800, Math::factorial(10));
    }

    #[test]
    fn test_nth_triangular() {
        assert_eq!(1, Math::nth_triangular(1));
        assert_eq!(3, Math::nth_triangular(2));
        assert_eq!(21, Math::nth_triangular(6));
    }

    #[test]
    fn test_fibonacci() {
        let i = Math::fibonacci();
        let act: Vec<u32> = i.take(7).map(|n| u32::try_from(n).unwrap()).collect();
        assert_eq!(vec![1, 1, 2, 3, 5, 8, 13], act);
    }
}
