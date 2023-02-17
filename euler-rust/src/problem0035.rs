/// Problem 35: [Circular primes](https://projecteuler.net/problem=35)

use crate::primes::Primes;

pub struct Problem0035 { }

impl Problem0035 {
    /// Find the number of circular primes below one million.
    #[must_use]
    pub fn solve() -> u32 {
        let mut n_circular: u32 = 0;
        let primes = Primes::new(1_000_000).unwrap();
        for p in primes.iter() {
            if Self::is_circular_prime(p, &primes) {
                n_circular += 1;
            }
        }
        n_circular
    }

    fn is_circular_prime(n: u32, primes: &Primes) -> bool {
        for r in Self::rotations(n).into_iter() {
            if !primes.test(r).unwrap() {
                return false;
            }
        }
        true
    }

    fn rotations(n: u32) -> Vec<u32> {
        let s = n.to_string();
        (0..s.len())
            .map(|i| {
                if i == 0 {
                    n
                } else {
                    let rs = format!("{}{}", s[i..s.len()].to_string(), s[0..i].to_string());
                    rs.parse::<u32>().unwrap()
                }
            })
            .collect()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 35 answer is {}", Self::solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_problem() {
        let answer = Problem0035::solve();
        assert_eq!(55, answer);
    }

    #[test]
    fn test_is_circular_prime() {
        let primes = Primes::new(1_000).unwrap();
        assert_eq!(true, Problem0035::is_circular_prime(197, &primes), "197 is a circular prime");
        assert_eq!(false, Problem0035::is_circular_prime(193, &primes), "193 is a circular prime");
    }

    #[test]
    fn test_rotations() {
        assert_eq!(vec![7], Problem0035::rotations(7), "7 rotations");
        assert_eq!(vec![97, 79], Problem0035::rotations(97), "97 rotations");
        assert_eq!(vec![197, 971, 719], Problem0035::rotations(197), "197 rotations");
    }
}
