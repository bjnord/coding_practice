/// Problem 25: [1000-digit Fibonacci number](https://projecteuler.net/problem=25)

use crate::math::Math;
use rug::{ops::Pow, Integer};

pub struct Problem0025 { }

impl Problem0025 {
    /// Find the index of the first term in the Fibonacci sequence to
    /// contain `d` digits.
    #[must_use]
    pub fn solve(d: usize) -> usize {
        let base = Integer::from(10);
        let limit = base.pow(d as u32 - 1);
        Math::fibonacci().position(|f| f >= limit).unwrap() + 1
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 25 answer is {}", Self::solve(1_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0025::solve(3);
        assert_eq!(12, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0025::solve(1_000);
        assert_eq!(4782, answer);
    }
}
