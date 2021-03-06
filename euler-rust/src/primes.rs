/// Prime number functions

use custom_error::custom_error;
use std::convert::TryFrom;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub PrimesError
    InvalidMaxValue = "invalid max value",
    ValueOutOfRange = "value out of range",
}

pub struct Primes {
    max: u32,
    is_prime: Vec<bool>,
}

pub struct PrimesIter<'a> {
    primes: &'a Primes,
    i: u32,
}

impl<'a> Iterator for PrimesIter<'a> {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        self.i += 1;
        loop {
            match self.primes.test(self.i) {
                Err(_) => return None,
                Ok(false) => self.i += 1,
                Ok(true) => return Some(self.i),
            }
        }
    }
}

impl Primes {
    /// Construct for the given `max` value. Uses the Sieve of Eratosthenes
    /// algorithm.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the given `max` value is invalid.
    pub fn new(max: u32) -> Result<Primes> {
        if max < 1 {
            return Err(PrimesError::InvalidMaxValue.into());
        }
        let max_us = usize::try_from(max).unwrap();
        let mut is_prime: Vec<bool> = vec![true; max_us + 1];
        for n in 2..=max {
            let n_us = usize::try_from(n).unwrap();
            if !is_prime[n_us] {
                continue;
            }
            let mut i = n * 2;
            while i <= max {
                let i_us = usize::try_from(i).unwrap();
                is_prime[i_us] = false;
                i += n;
            }
        }
        Ok(Self { max, is_prime })
    }

    /// Return all prime numbers (within the initialized range).
    #[must_use]
    pub fn all(&self) -> Vec<u32> {
        (1..=self.max)
            .filter(|&n| {
                let n_us = usize::try_from(n).unwrap();
                self.is_prime[n_us]
            })
            .collect()
    }

    /// Is the given `n` a prime number?
    ///
    /// # Errors
    ///
    /// Returns `Err` if the given `n` value is out of range.
    pub fn test(&self, n: u32) -> Result<bool> {
        if n < 1 || n > self.max {
            return Err(PrimesError::ValueOutOfRange.into());
        }
        let n_us = usize::try_from(n).unwrap();
        Ok(self.is_prime[n_us])
    }

    pub fn iter(&self) -> PrimesIter {
        PrimesIter { primes: &self, i: 1 }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // TODO test new() with invalid max

    #[test]
    fn test_all() {
        let primes = Primes::new(120).unwrap();
        let expected = vec![1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
            31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
            73, 79, 83, 89, 97, 101, 103, 107, 109, 113];
        assert_eq!(expected, primes.all());
    }

    #[test]
    fn test_prime() {
        let primes = Primes::new(120).unwrap();
        assert_eq!(true, primes.test(1).unwrap());
        assert_eq!(true, primes.test(3).unwrap());
        assert_eq!(true, primes.test(5).unwrap());
        assert_eq!(true, primes.test(11).unwrap());
        assert_eq!(true, primes.test(53).unwrap());
        assert_eq!(true, primes.test(113).unwrap());
    }

    #[test]
    fn test_composite() {
        let primes = Primes::new(120).unwrap();
        assert_eq!(false, primes.test(4).unwrap());
        assert_eq!(false, primes.test(9).unwrap());
        assert_eq!(false, primes.test(25).unwrap());
        assert_eq!(false, primes.test(70).unwrap());
        assert_eq!(false, primes.test(91).unwrap());
        assert_eq!(false, primes.test(120).unwrap());
    }

    // TODO test test() with n < 1 and n > max

    #[test]
    fn test_iter() {
        let primes = Primes::new(120).unwrap();
        let mut iter = primes.iter();
        assert_eq!(2, iter.next().unwrap());
        assert_eq!(3, iter.next().unwrap());
        assert_eq!(5, iter.next().unwrap());
        assert_eq!(7, iter.next().unwrap());
    }

    #[test]
    fn test_iter_none() {
        let primes = Primes::new(6).unwrap();
        let mut iter = primes.iter();
        assert_eq!(2, iter.next().unwrap());
        assert_eq!(3, iter.next().unwrap());
        assert_eq!(5, iter.next().unwrap());
        assert_eq!(true, iter.next().is_none());
    }
}
