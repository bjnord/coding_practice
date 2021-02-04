/// General math functions

const MAX_52_BIT: u64 = 4_503_599_627_370_495;

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
}
