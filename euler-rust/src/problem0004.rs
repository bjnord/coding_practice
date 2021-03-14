/// Problem 4: [Largest palindrome product](https://projecteuler.net/problem=4)

use std::cmp;

pub struct Problem0004 { }

impl Problem0004 {
    /// Find the largest palindrome made from the product of two `n`-digit
    /// numbers.
    #[must_use]
    pub fn solve(n: u32) -> u32 {
        let max = 10_u32.pow(n);
        let mut max_pal = 0_u32;
        for a in 1..=max {
            let rev_a = max - a;
            for b in 1..=max {
                let prod = rev_a * (max - b);
                if Problem0004::is_palindrome(prod) {
                    max_pal = cmp::max(max_pal, prod);
                }
            }
        }
        max_pal
    }

    /// Is `n` a palindrome?
    #[must_use]
    pub fn is_palindrome(n: u32) -> bool {
        let s: String = n.to_string();
        let t: String = s.chars().rev().collect();
        s == t
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 4 answer is {}", Self::solve(3))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_palindrome() {
        assert_eq!(true, Problem0004::is_palindrome(102201));
        assert_eq!(true, Problem0004::is_palindrome(2112));
        assert_eq!(true, Problem0004::is_palindrome(81518));
    }

    #[test]
    fn test_not_is_palindrome() {
        assert_eq!(false, Problem0004::is_palindrome(101201));
        assert_eq!(false, Problem0004::is_palindrome(2312));
        assert_eq!(false, Problem0004::is_palindrome(82518));
    }

    #[test]
    fn test_solve_example() {
        let answer = Problem0004::solve(2);
        assert_eq!(9009, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0004::solve(3);
        assert_eq!(906609, answer);
    }
}
