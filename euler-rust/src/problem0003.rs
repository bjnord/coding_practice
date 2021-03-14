/// Problem 3: [Largest prime factor](https://projecteuler.net/problem=3)

use crate::math::Math;
use crate::primes::Primes;
use std::convert::TryFrom;

const PROBLEM_VALUE: u64 = 600_851_475_143;

pub struct Problem0003 { }

impl Problem0003 {
    /// Find the largest prime factor of the given number.
    #[must_use]
    pub fn solve(n: u64) -> u64 {
        let primes = Primes::new(Math::isqrt_64(n) + 1).unwrap();
        let largest: Option<u32> = primes.all()
            .into_iter()
            .rev()
            .find(|&p| {
                let p64 = u64::try_from(p).unwrap();
                n.rem_euclid(p64) == 0
            });
        u64::try_from(largest.unwrap()).unwrap()
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
    fn test_solve_example() {
        let answer = Problem0003::solve(13195);
        assert_eq!(29, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0003::solve(PROBLEM_VALUE);
        assert_eq!(6857, answer);
    }
}
