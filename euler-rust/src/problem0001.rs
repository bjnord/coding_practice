/// Problem 1: [Multiples of 3 and 5](https://projecteuler.net/problem=1)

pub struct Problem0001 { }

impl Problem0001 {
    /// Find the sum of all the natural numbers which are multiples of
    /// 3 or 5 below the given value.
    #[must_use]
    pub fn solve(below: u32) -> u32 {
        (1..below)
            .filter(|n| n.rem_euclid(3) == 0 || n.rem_euclid(5) == 0)
            .sum()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 1 answer is {}", Self::solve(1000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0001::solve(10);
        assert_eq!(23, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0001::solve(1000);
        assert_eq!(233168, answer);
    }
}
