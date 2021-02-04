/// Problem 3: [Largest prime factor](https://projecteuler.net/problem=3)

use crate::primes::Primes;
use std::convert::TryFrom;

const PROBLEM_VALUE: u64 = 600_851_475_143;
const MAX_52_BIT: u64 = 4_503_599_627_370_495;

pub struct Problem0003 { }

impl Problem0003 {
    /// Find the largest prime factor of the given number.
    #[must_use]
    pub fn solve(n: u64) -> u64 {
        let primes = Primes::new(Problem0003::isqrt(n) + 1).unwrap();
        let largest: Option<u32> = primes.all()
            .into_iter()
            .rev()
            .find(|&p| {
                let p64 = u64::try_from(p).unwrap();
                n.rem_euclid(p64) == 0
            });
        u64::try_from(largest.unwrap()).unwrap()
    }

    // h/t <https://users.rust-lang.org/t/integer-square-root/96>
    #[allow(clippy::cast_possible_truncation)]
    #[allow(clippy::cast_precision_loss)]
    #[allow(clippy::cast_sign_loss)]
    fn isqrt(n: u64) -> u32 {
        // f64 only has 52-bit mantissa
        if n > MAX_52_BIT {
            panic!("n={} too large", n);
        }
        // sqrt of 52-bit number will fit in u32
        (n as f64).sqrt() as u32
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 3 answer is {}", Self::solve(PROBLEM_VALUE))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_max_n_isqrt() {
        let ns = Problem0003::isqrt(MAX_52_BIT);
        assert_eq!(67_108_863, ns);
    }

    #[test]
    #[should_panic]
    fn test_big_n_isqrt() {
        Problem0003::isqrt(MAX_52_BIT + 1);
    }

    #[test]
    fn test_solve_example() {
        let answer = Problem0003::solve(13195);
        assert_eq!(29, answer);
    }

    #[test]
    fn test_solve_problem() {
        let answer = Problem0003::solve(PROBLEM_VALUE);
        assert_eq!(6857, answer);
    }
}
