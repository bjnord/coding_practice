/// Problem 26: [Reciprocal cycles](https://projecteuler.net/problem=26)

use crate::math::Math;

#[derive(PartialEq, Eq, PartialOrd, Ord)]
struct RepeatLen {
    len: usize,
    d: u32,
}

pub struct Problem0026 { }

impl Problem0026 {
    /// Find the value of d < `n` for which 1/d contains the longest
    /// recurring cycle in its decimal fraction part, using the given
    /// precision `prec` (bits).
    #[must_use]
    pub fn solve(n: u32) -> u32 {
        (2..n).map(|d| Self::repeat_len(d)).max().unwrap().d
    }

    // Find the length of the repeating portion of `1/d`.
    fn repeat_len(d: u32) -> RepeatLen {
        RepeatLen { len: Math::repetend(1, d).1.len(), d }
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 26 answer is {}", Self::solve(1_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0026::solve(11);
        assert_eq!(7, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0026::solve(1_000);
        assert_eq!(983, answer);
    }
}
