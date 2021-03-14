/// Problem 5: [Smallest multiple](https://projecteuler.net/problem=5)

use crate::factorizer::NaiveFactorizer;
use crate::primes::Primes;
use std::cmp;
use std::collections::HashMap;

pub struct Problem0005 { }

impl Problem0005 {
    /// Find the smallest number that can be divided by each of the numbers
    /// from 1 to `n` without any remainder
    #[must_use]
    pub fn solve(n: u32) -> u32 {
        let primes = Primes::new(n).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let mut max_factors: HashMap<u32, usize> = hashmap!{};
        for i in 2..=n {
            let factors = factorizer.factorize(i).unwrap();
            for (p, count) in factors.iter() {
                if max_factors.contains_key(p) {
                    let max = cmp::max(*max_factors.get(p).unwrap(), *count);
                    max_factors.insert(*p, max);
                } else {
                    max_factors.insert(*p, *count);
                }
            }
        }
        let mut solution: u32 = 1;
        for (p, &count) in max_factors.iter() {
            for _i in 1..=count {
                solution *= p;
            }
        }
        solution
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 5 answer is {}", Self::solve(20))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0005::solve(10);
        assert_eq!(2520, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0005::solve(20);
        assert_eq!(232792560, answer);
    }
}
