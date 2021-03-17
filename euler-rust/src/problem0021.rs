/// Problem 21: [Amicable numbers](https://projecteuler.net/problem=21)

use crate::factorizer::NaiveFactorizer;
use crate::primes::Primes;

pub struct Problem0021 { }

impl Problem0021 {
    /// Find the sum of all the amicable numbers under `n`.
    #[must_use]
    pub fn solve(n: u32) -> u32 {
        let primes = Primes::new(n).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let mut dsum: Vec<u32> = (0..=n)
            .map(|i| factorizer.proper_divisor_sum(i))
            .collect();
        for i in 0..=n {
            let ius = i as usize;
            if dsum[ius] == 0 {
                continue;
            }
            // not amicable: points to itself
            if dsum[ius] == i {
                dsum[ius] = 0;
                continue;
            }
            // not amicable: points beyond vector
            if dsum[ius] > n {
                dsum[ius] = 0;
                continue;
            }
            // not amicable: points to something that doesn't point back
            if dsum[dsum[ius] as usize] != i {
                dsum[ius] = 0;
                continue;
            }
            // amicable! leave it in the vector
        }
        dsum.iter().sum()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 21 answer is {}", Self::solve(10_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0021::solve(1_000);
        assert_eq!(220 + 284, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0021::solve(10_000);
        assert_eq!(31626, answer);
    }
}
