/// Problem 16: [Power digit sum](https://projecteuler.net/problem=16)

use crate::bcd::DoubleDabbler;

pub struct Problem0016 { }

impl Problem0016 {
    /// Find the sum of the digits of `2^p`.
    #[must_use]
    pub fn solve(p: usize) -> u32 {
        let dabbler = DoubleDabbler::from_power(p).unwrap();
        dabbler.digits().iter().map(|&d| d as u32).sum()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 16 answer is {}", Self::solve(1_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0016::solve(15);
        assert_eq!(26, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0016::solve(1_000);
        assert_eq!(1366, answer);
    }
}
