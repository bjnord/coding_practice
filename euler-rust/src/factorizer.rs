/// Prime factorization function (naive method)

use custom_error::custom_error;
use crate::primes::Primes;
use std::collections::HashMap;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub NaiveFactorizerError
    ValueOutOfRange = "value out of range",
}

pub struct NaiveFactorizer<'a> {
    tester: &'a Primes,
}

impl<'a> NaiveFactorizer<'a> {
    /// Construct a new factorizer which will use prime tester `tester`.
    pub fn new(tester: &'a Primes) -> Result<NaiveFactorizer> {
        Ok(Self { tester })
    }

    /// Return the prime factors of `n` (not including 1) as a hash:
    /// - key is the prime factor
    /// - value is the number of occurrences
    ///
    /// # Examples
    ///
    /// ```
    /// # use euler_rust::factorizer::NaiveFactorizer;
    /// # use euler_rust::primes::Primes;
    /// # use maplit::hashmap;
    /// let primes = Primes::new(120).unwrap();
    /// let factorizer = NaiveFactorizer::new(&primes).unwrap();
    /// let factors = factorizer.factorize(2260).unwrap();
    /// assert_eq!(hashmap!{2 => 2, 5 => 1, 113 => 1}, factors);
    /// ```
    pub fn factorize(&self, n: u32) -> Result<HashMap<u32, usize>> {
        if n < 1 {
            return Err(NaiveFactorizerError::ValueOutOfRange.into());
        }
        let mut factors: HashMap<u32, usize> = hashmap!{};
        let mut n1 = n;
        loop {
            if n1 == 1 {
                break;
            }
            for i in 2..=n1 {
                let t = match self.tester.test(i) {
                    Err(e) => { return Err(e) },
                    Ok(false) => false,
                    Ok(true) => n1.rem_euclid(i) == 0,
                };
                if t {
                    n1 = n1 / i;
                    *factors.entry(i).or_insert(0) += 1;
                    break;
                }
            }
        }
        Ok(factors)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_out_of_range_factorize() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        match factorizer.factorize(0) {
            Err(e) => assert_eq!("value out of range", e.to_string()),
            Ok(_) => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_small_max_factorize() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        match factorizer.factorize(81518) {
            Err(e) => assert_eq!("value out of range", e.to_string()),
            Ok(_) => panic!("test did not fail"),
        }
    }
}
