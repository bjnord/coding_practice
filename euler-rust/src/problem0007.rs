/// Problem 7: [10001st prime](https://projecteuler.net/problem=7)

use crate::primes::Primes;

pub struct Problem0007 { }

impl Problem0007 {
    /// Find the `n`th prime number.
    #[must_use]
    pub fn solve(n: usize) -> u32 {
        let primes = Primes::new(1_000_000).unwrap();
        let mut iter = primes.iter();
        let mut nth = 1;
        for _i in 1..=n {
            nth = iter.next().unwrap();
        }
        nth
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 7 answer is {}", Self::solve(10_001))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0007::solve(6);
        assert_eq!(13, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0007::solve(10_001);
        assert_eq!(104743, answer);
    }
}
