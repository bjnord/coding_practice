/// Problem 20: [Factorial digit sum](https://projecteuler.net/problem=20)

use crate::math::Math;

pub struct Problem0020 { }

impl Problem0020 {
    /// Find the sum of the digits of `n!`.
    //
    // After thinking about it, I realized I could remove all powers of 2*5
    // (since extra 0s won't affect the sum). But I suspected 100! still
    // would not fit in a u64, so I went with the `rug` crate for arbitrary
    // precision numbers.
    #[must_use]
    pub fn solve(n: u32) -> u32 {
        let fact = Math::factorial(n);
        //eprintln!("n={} bits={}", n, fact.significant_bits());
        fact.to_string().chars().map(|c| c.to_digit(10).unwrap()).sum()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 20 answer is {}", Self::solve(100))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0020::solve(10);
        assert_eq!(27, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0020::solve(100);
        assert_eq!(648, answer);
    }
}
