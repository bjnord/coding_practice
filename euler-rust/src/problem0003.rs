/// Problem 3: [Largest prime factor](https://projecteuler.net/problem=3)

use crate::primes::Primes;

const PROBLEM_VALUE: u64 = 600_851_475_143;

pub struct Problem0003 { }

impl Problem0003 {
    /// Find the largest prime factor of the given number.
    #[must_use]
    pub fn solve(n: u64) -> u64 {
        let n_sqrt: u32 = (n as f64).sqrt() as u32;
        let primes = Primes::new(n_sqrt + 1).unwrap();
        let largest: Option<u32> = primes.all()
            .into_iter()
            .rev()
            .find(|&p| n.rem_euclid(p as u64) == 0);
        largest.unwrap() as u64
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
    fn test_solve_problem() {
        let answer = Problem0003::solve(PROBLEM_VALUE);
        assert_eq!(6857, answer);
    }
}
