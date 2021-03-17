/// Problem 12: [Highly divisible triangular number](https://projecteuler.net/problem=12)

use crate::factorizer::NaiveFactorizer;
use crate::math::Math;
use crate::primes::Primes;

pub struct Problem0012 { }

impl Problem0012 {
    /// Find the first triangular number with over `n` divisors (including
    /// 1 and itself).
    #[must_use]
    pub fn solve(n: usize) -> u32 {
        let primes = Primes::new(1_000_000).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        for i in 2_usize..=std::usize::MAX {
            let tri = Math::nth_triangular(i);
            let factors = factorizer.factorize(tri).unwrap();
            if NaiveFactorizer::n_divisors(&factors) > n {
                return tri;
            }
        }
        0
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 12 answer is {}", Self::solve(500))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0012::solve(5);
        assert_eq!(28, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0012::solve(500);
        assert_eq!(76576500, answer);
    }
}
