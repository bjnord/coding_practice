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

    /// Return the sum of the proper divisors of `n` that are less than `n`
    /// (including 1).
    pub fn proper_divisor_sum(&self, n: u32) -> u32 {
        if n < 2 {
            return 0;
        }
        let factors = self.factorize(n).unwrap();
        Self::divisors(&factors).iter().filter(|d| **d < n).sum()
    }

    // h/t: <https://mathschallenge.net/library/number/number_of_divisors>
    //      <https://www2.math.upenn.edu/~deturck/m170/wk2/numdivisors.html>
    pub fn n_divisors(factors: &HashMap<u32, usize>) -> usize {
        factors.values().map(|f| f+1).product()
    }

    // TODO RF clean this up -- perhaps itertools combinations?
    pub fn divisors(factors: &HashMap<u32, usize>) -> Vec<u32> {
        let mut f: Vec<u32> = Vec::new();
        for (&n, &p) in factors.iter() {
            for _i in 1..=p {
                f.push(n);
            }
        }
        f.sort();
        let c = 2_u32.pow(f.len() as u32);
        let mut div: Vec<u32> = Vec::new();
        for m in 0..c {
            let mut d = 1;
            let mut i = 0;
            let mut b = 0x1;
            while b < c {
                if m & b != 0x0 {
                    d *= f[i];
                }
                i += 1;
                b <<= 1;
            }
            div.push(d);
        }
        div.sort();
        div.dedup();
        div
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

    #[test]
    fn test_proper_divisor_sum() {
        let primes = Primes::new(284).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        assert_eq!(284, factorizer.proper_divisor_sum(220));
        assert_eq!(220, factorizer.proper_divisor_sum(284));
    }

    #[test]
    fn test_n_divisors() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let mut factors = factorizer.factorize(21).unwrap();
        assert_eq!(2*2, NaiveFactorizer::n_divisors(&factors));
        factors = factorizer.factorize(2260).unwrap();
        assert_eq!(3*2*2, NaiveFactorizer::n_divisors(&factors));
    }

    #[test]
    fn test_divisors() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let mut factors = factorizer.factorize(21).unwrap();
        assert_eq!(vec![1, 3, 7, 21], NaiveFactorizer::divisors(&factors));
        factors = factorizer.factorize(12).unwrap();
        assert_eq!(vec![1, 2, 3, 4, 6, 12], NaiveFactorizer::divisors(&factors));
        factors = factorizer.factorize(2260).unwrap();
        assert_eq!(vec![1, 2, 4, 5, 10, 20, 113, 226, 452, 565, 1130, 2260], NaiveFactorizer::divisors(&factors));
    }
}
