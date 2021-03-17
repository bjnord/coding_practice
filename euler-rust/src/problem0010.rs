/// Problem 10: [Summation of primes](https://projecteuler.net/problem=10)

use crate::primes::Primes;

pub struct Problem0010 { }

impl Problem0010 {
    /// Find the sum of the primes below `n`.
    #[must_use]
    pub fn solve(n: u32) -> u64 {
        let primes = Primes::new(2_001_000).unwrap();
        let mut iter = primes.iter();
        let mut sum: u64 = 0;
        let mut p: u32 = iter.next().unwrap();
        while p < n {
            sum += p as u64;
            p = iter.next().unwrap();
        }
        sum
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 10 answer is {}", Self::solve(2_000_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0010::solve(10);
        assert_eq!(17, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0010::solve(2_000_000);
        assert_eq!(142913828922, answer);
    }
}
