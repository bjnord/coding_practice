/// Problem 2: [Even Fibonacci numbers](https://projecteuler.net/problem=2)

use crate::math::Math;
use std::convert::TryFrom;

pub struct Problem0002 { }

impl Problem0002 {
    /// Find the sum of the even terms in the Fibonacci sequence whose
    /// values do not exceed the given value.
    #[must_use]
    pub fn solve(limit: u32) -> u32 {
        let mut sum = 0;
        let mut fib = Math::fibonacci();
        loop {
            let f = fib.next().unwrap();
            let c: u32 = u32::try_from(f).unwrap();
            if c > limit {
                break;
            }
            if c & 0x1 == 0x0 {
                sum += c;
            }
        }
        sum
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 2 answer is {}", Self::solve(4_000_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0002::solve(1_000);
        assert_eq!(798, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0002::solve(4_000_000);
        assert_eq!(4613732, answer);
    }
}
