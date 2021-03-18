/// Problem 24: [Lexicographic permutations](https://projecteuler.net/problem=24)

use itertools::Itertools;
use std::char;
use std::ops::Range;

pub struct Problem0024 { }

impl Problem0024 {
    /// Find the `n`th permutation of the given range of digits.
    #[must_use]
    pub fn solve(n: usize, r: Range<usize>) -> String {
        let len = r.end - r.start;
        let perms = r.permutations(len);
        let nth = perms.skip(n-1).next().unwrap();
        nth.iter()
            .map(|&i| char::from_digit(i as u32, 10).unwrap())
            .collect()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 24 answer is {}", Self::solve(1_000_000, 0..10))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0024::solve(5, 0..3);
        assert_eq!("201", answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0024::solve(1_000_000, 0..10);
        assert_eq!("2783915460", answer);
    }
}
