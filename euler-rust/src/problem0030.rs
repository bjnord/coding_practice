/// Problem 30: [Digit fifth powers](https://projecteuler.net/problem=30)

pub struct Problem0030 { }

impl Problem0030 {
    /// Find the sum of all the numbers that can be written as the sum of their
    /// digits each raised to the `p` power.
    #[must_use]
    pub fn solve(p: u32) -> u32 {
        // I'm not sure how to know when to stop checking for a given `p`;
        // this is to make the example test run reasonably fast:
        let limit: u32 = match p {
            4 => 10_000,
            _ => 1_000_000,
        };
        // "As `1 = 1^4` is not a sum it is not included."
        (2..=limit)
            .filter(|&n| Self::is_power_digits(n, p))
            .sum()
    }

    fn is_power_digits(n: u32, p: u32) -> bool {
        let s = n.to_string();
        let sum: u32 = s.chars()
            .map(|c| c.to_digit(10).unwrap().pow(p))
            .sum();
        sum == n
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 30 answer is {}", Self::solve(5))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0030::solve(4);
        assert_eq!(19316, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0030::solve(5);
        assert_eq!(443839, answer);
    }
}
