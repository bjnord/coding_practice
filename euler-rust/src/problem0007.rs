/// Problem 7: [10001st prime](https://projecteuler.net/problem=7)

use crate::primes::Primes;

pub struct Problem0007 { }

impl Problem0007 {
    /// Find the `n`th prime number.
    #[must_use]
    pub fn nth_prime(n: usize) -> u32 {
        let primes = Primes::new(1_000_000).unwrap();
        let mut iter = primes.iter();
        let mut nth = 1;
        for _i in 1..=n {
            nth = iter.next().unwrap();
        }
        nth
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 7 answer is {}", Self::nth_prime(10_001))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_nth_prime_example() {
        let answer = Problem0007::nth_prime(6);
        assert_eq!(13, answer);
    }

    #[test]
    #[ignore]
    fn test_nth_prime_problem() {
        let answer = Problem0007::nth_prime(10_001);
        assert_eq!(104743, answer);
    }
}
