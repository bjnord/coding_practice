/// Problem 6: [Sum square difference](https://projecteuler.net/problem=6)

pub struct Problem0006 { }

impl Problem0006 {
    /// Find the difference between the sum of the squares of the first `n`
    /// natural numbers, and the square of the sum.
    #[must_use]
    pub fn solve(n: u64) -> u64 {
      let sum: u64 = (1..=n).sum();
      let sq_sum: u64 = sum * sum;
      let sum_sq: u64 = (1..=n)
          .map(|n| n*n)
          .sum();
      sq_sum - sum_sq
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 6 answer is {}", Self::solve(100))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0006::solve(10);
        assert_eq!(2640, answer);
    }

    #[test]
    fn test_solve_problem() {
        let answer = Problem0006::solve(100);
        assert_eq!(25164150, answer);
    }
}
