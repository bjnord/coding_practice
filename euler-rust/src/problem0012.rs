/// Problem 12: [Highly divisible triangular number](https://projecteuler.net/problem=12)

use crate::factorizer::NaiveFactorizer;
use crate::primes::Primes;
use std::convert::TryFrom;

pub struct Problem0012 { }

impl Problem0012 {
    /// Find the first triangular number with over `n` divisors (including
    /// 1 and itself).
    #[must_use]
    pub fn solve(n: usize) -> u32 {
        let primes = Primes::new(1_000_000).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        for i in 2_usize..=std::usize::MAX {
            let tri = Self::nth_triangular(i);
            let factors = factorizer.factorize(tri).unwrap();
            // h/t: <https://mathschallenge.net/library/number/number_of_divisors>
            //      <https://www2.math.upenn.edu/~deturck/m170/wk2/numdivisors.html>
            // TODO move this to NaiveFactorizer
            let n_divisors: usize = factors.values().map(|f| f+1).product();
            if n_divisors > n {
                return tri;
            }
        }
        0
    }

    // TODO move this to math
    fn nth_triangular(n: usize) -> u32 {
        let tri = n * (n + 1) / 2;
        u32::try_from(tri).unwrap()
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
