/// Problem 32: [Pandigital products](https://projecteuler.net/problem=32)

use std::collections::HashSet;

pub struct Problem0032 { }

impl Problem0032 {
    /// Find the sum of all products whose multiplicand/multiplier/product
    /// identity can be written as a 1 through 9 pandigital. An n-digit
    /// number is _pandigital_ if it makes use of all the digits 1 to n
    /// exactly once.
    #[must_use]
    pub fn solve() -> u32 {
        let mut seen: HashSet<u32> = HashSet::new();
        // A 5-digit `a` times the smallest `b=2` would yield at least a
        // 5-digit product, which takes us over 9 digits.
        for a in 2..10_000 {
            for b in a+1..10_000 {
                let c = a * b;
                // Conversely, a 5-digit `c` leaves only 4 digits for `a`
                // and `b`, and the biggest of these (`9 * 999` or
                // `99 * 99`) do not reach 5 digits.
                if c >= 10_000 {
                    continue;
                }
                if Self::is_pandigital(a, b, c) {
                    if !seen.contains(&c) {
                        seen.insert(c);
                    }
                }
            }
        }
        seen.iter().sum()
    }

    // Is `a * b = c` pandigital?
    fn is_pandigital(a: u32, b: u32, c: u32) -> bool {
        let a_s = a.to_string();
        if a_s.contains("0") {
            return false;
        }
        let b_s = b.to_string();
        if b_s.contains("0") {
            return false;
        }
        let c_s = c.to_string();
        if c_s.contains("0") {
            return false;
        }
        let all_s = format!("{}{}{}", a_s, b_s, c_s);
        if all_s.len() != 9 {
            return false;
        }
        let mut sch: Vec<char> = all_s.chars().collect();
        sch.sort();
        sch == vec!['1', '2', '3', '4', '5', '6', '7', '8', '9']
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 32 answer is {}", Self::solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0032::solve();
        assert_eq!(45228, answer);
    }

    #[test]
    fn test_is_pandigital() {
        assert_eq!(true, Problem0032::is_pandigital(39, 186, 7254));
        assert_eq!(false, Problem0032::is_pandigital(39, 106, 4134));
        assert_eq!(false, Problem0032::is_pandigital(40, 186, 7440));
        assert_eq!(false, Problem0032::is_pandigital(132, 56, 7392));
    }
}
