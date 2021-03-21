/// Problem 34: [Digit factorials](https://projecteuler.net/problem=34)

use crate::math::Math;

pub struct Problem0034 { }

impl Problem0034 {
    /// Find the sum of all numbers which are equal to the sum of the
    /// factorial of their digits.
    #[must_use]
    pub fn solve() -> u32 {
        (3..100_000)
            .filter(|n| Self::is_digit_factorial(*n))
            .sum()
    }

    fn is_digit_factorial(n: u32) -> bool {
        if n <= 2 {
            return false;
        }
        let nfsum: u32 = n.to_string()
            .chars()
            .map(|c| c.to_digit(10).unwrap())
            .map(|d| Math::factorial(d).to_u32().unwrap())
            .sum();
        nfsum == n
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 34 answer is {}", Self::solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0034::solve();
        assert_eq!(40730, answer);
    }

    #[test]
    fn test_is_digit_factorial() {
        assert_eq!(true, Problem0034::is_digit_factorial(145));
        assert_eq!(false, Problem0034::is_digit_factorial(146));
    }

    #[test]
    fn test_is_digit_factorial_excluded() {
        assert_eq!(false, Problem0034::is_digit_factorial(1));
        assert_eq!(false, Problem0034::is_digit_factorial(2));
    }
}
