/// Problem 27: [Quadratic primes](https://projecteuler.net/problem=27)

use crate::primes::Primes;
use std::convert::TryFrom;

const COEFF_LIMIT: i64 = 1000;
const MAX_PRIME: u32 = 1_000_000;

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct Coefficients {
    n: i64,
    a: i64,
    b: i64,
}

pub struct Problem0027 {
    primes: Primes,
}

impl Problem0027 {
    /// Construct with a prime tester.
    pub fn new() -> Self {
        let primes = Primes::new(MAX_PRIME).unwrap();
        Self { primes }
    }

    /// Find the product of the two coefficients `abs(a) < 1000` and
    /// `abs(b) <= 1000`, for the quadratic expression `n^2 + an + b`
    /// that produces the maximum number of primes for consecutive values
    /// of `n`, starting with 0.
    ///
    /// For example:
    /// - the quadratic with `a=1` and `b=41` produces primes when
    ///   `0 <= n <= 39`, so the product is `41`
    /// - the quadratic with `a=-79` and `b=1601` produces primes when
    ///   `0 <= n <= 79`, so the product is `-126479`
    #[must_use]
    pub fn solve(&self) -> i64 {
        let mut trials: Vec<Coefficients> = Vec::new();
        for a in (-COEFF_LIMIT+1)..=(COEFF_LIMIT-1) {
            for b in -COEFF_LIMIT..=COEFF_LIMIT {
                trials.push(self.try_coefficients(a, b));
            }
        }
        let max = trials.iter().max().unwrap();
        max.a * max.b
    }

    fn try_coefficients(&self, a: i64, b: i64) -> Coefficients {
        // find the first n for which the quadratic yields a non-prime
        for n in 0_i64..=std::i64::MAX {
            let mut p: i64 = n*n + a*n + b;
            if p < 1 {  // nonpositive numbers aren't prime
                p = 4;  // ...so make the prime test fail
            }
            let p0: u32 = u32::try_from(p).unwrap();
            if !self.primes.test(p0).unwrap() {
                // ...so the previous n is the last prime
                return Coefficients { a, b, n: n-1 }
            }
        }
        // alert the media!
        Coefficients { a, b, n: std::i64::MAX }
    }

    #[must_use]
    pub fn output() -> String {
        let problem = Problem0027::new();
        format!("Problem 27 answer is {}", problem.solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let problem = Problem0027::new();
        assert_eq!(-59231, problem.solve());
    }

    #[test]
    fn test_try_coefficients() {
        let problem = Problem0027::new();
        let mut coeff = problem.try_coefficients(1, 41);
        assert_eq!(39, coeff.n);
        coeff = problem.try_coefficients(-79, 1601);
        assert_eq!(79, coeff.n);
    }
}
