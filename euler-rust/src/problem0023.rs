/// Problem 23: [Non-abundant sums](https://projecteuler.net/problem=23)

use crate::factorizer::NaiveFactorizer;
use crate::primes::Primes;

const MIN_ABUNDANT_SUM: u32 = 24;
const MAX_NONABUNDANT_SUM: u32 = 28123;

pub struct Problem0023 {
    is_abundant: Vec<bool>,
}

impl Problem0023 {
    /// Construct the table of abundant numbers.
    pub fn new() -> Self {
        let primes = Primes::new(MAX_NONABUNDANT_SUM).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let a = (0..=MAX_NONABUNDANT_SUM).map(|n| Self::is_abundant(&factorizer, n)).collect();
        Self { is_abundant: a }
    }

    /// Find the sum of all the positive integers which cannot be written
    /// as the sum of two abundant numbers.
    #[must_use]
    pub fn solve(&self) -> u32 {
        // "As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16,
        // the smallest number that can be written as the sum of two abundant
        // numbers is 24." Therefore, all smaller positive integers can't be:
        let mut total_sum: u32 = (1..MIN_ABUNDANT_SUM).sum();
        // "By mathematical analysis, it can be shown that all integers
        // greater than 28123 can be written as the sum of two abundant
        // numbers." Therefore, we only need to go up through that integer:
        for a_sum in (MIN_ABUNDANT_SUM+1)..=MAX_NONABUNDANT_SUM {
            let mut can_be: bool = false;
            for a1 in 12..=(a_sum/2) {
                let a2 = a_sum - a1;
                if self.is_abundant[a1 as usize] && self.is_abundant[a2 as usize] {
                    can_be = true;
                    break;
                }
            }
            if !can_be {
                total_sum += a_sum;
            }
        }
        total_sum
    }

    fn is_abundant(factorizer: &NaiveFactorizer, n: u32) -> bool {
        let dsum: u32 = factorizer.proper_divisor_sum(n);
        dsum > n
    }

    #[must_use]
    pub fn output() -> String {
        let problem = Problem0023::new();
        format!("Problem 23 answer is {}", problem.solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let problem = Problem0023::new();
        assert_eq!(4179871, problem.solve());
    }

    #[test]
    fn test_is_abundant() {
        let primes = Primes::new(MAX_NONABUNDANT_SUM).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        assert_eq!(false, Problem0023::is_abundant(&factorizer, 1));
        assert_eq!(true, Problem0023::is_abundant(&factorizer, 12));
        assert_eq!(false, Problem0023::is_abundant(&factorizer, 32));
        assert_eq!(true, Problem0023::is_abundant(&factorizer, 36));
    }
}
