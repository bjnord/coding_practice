/// General math functions

use crate::factorizer::NaiveFactorizer;
use rug::{Assign, Integer};
use std::collections::HashMap;
use std::convert::TryFrom;
use std::fmt;

const MAX_52_BIT: u64 = 4_503_599_627_370_495;
const MAX_52_BIT_I64: i64 = 4_503_599_627_370_495;

pub struct FibonacciIter {
    f1: Integer,
    f2: Integer,
}

impl Iterator for FibonacciIter {
    type Item = Integer;

    fn next(&mut self) -> Option<Self::Item> {
        let f3 = Integer::from(&self.f1 + &self.f2);
        self.f1.assign(&self.f2);
        self.f2.assign(f3);
        let f = Integer::from(&self.f1);
        Some(f)
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct IntFraction {
    pub num: i64,
    pub denom: i64,
}

impl fmt::Display for IntFraction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}/{}", self.num, self.denom)
    }
}

impl IntFraction {
    pub fn new(num: i64, denom: i64) -> Self {
        Self { num, denom }
    }

    pub fn mult(&self, int_f: Self) -> Self {
        Self { num: self.num * int_f.num, denom: self.denom * int_f.denom }
    }

    pub fn reduce(&self, factorizer: &NaiveFactorizer) -> Self {
        if self.denom.rem_euclid(self.num) == 0 {
            return Self { num: 1, denom: self.denom / self.num }
        }
        let num: u32 = u32::try_from(self.num.abs()).unwrap();
        let denom: u32 = u32::try_from(self.denom.abs()).unwrap();
        let gcf: i64 = factorizer.gcf(num, denom).unwrap() as i64;
        return Self { num: self.num / gcf, denom: self.denom / gcf }
    }

    // FIXME this should be done within the integer realm
    pub fn equals(&self, int_f: Self) -> bool {
        // f64 only has 52-bit mantissa
        if self.num > MAX_52_BIT_I64 || self.denom > MAX_52_BIT_I64 {
            panic!("self too large");
        } else if int_f.num > MAX_52_BIT_I64 || int_f.denom > MAX_52_BIT_I64 {
            panic!("arg too large");
        }
        let first = self.num as f64 / self.denom as f64;
        let second = int_f.num as f64 / int_f.denom as f64;
        (first - second).abs() < 0.000_000_000_001
    }
}

pub struct Math { }

impl Math {
    // h/t <https://users.rust-lang.org/t/integer-square-root/96>
    #[allow(clippy::cast_possible_truncation)]
    #[allow(clippy::cast_precision_loss)]
    #[allow(clippy::cast_sign_loss)]
    pub fn isqrt_64(n: u64) -> u32 {
        // f64 only has 52-bit mantissa
        if n > MAX_52_BIT {
            panic!("n={} too large", n);
        }
        // sqrt of 52-bit number will fit in u32
        (n as f64).sqrt() as u32
    }

    // h/t <https://users.rust-lang.org/t/integer-square-root/96>
    #[allow(clippy::cast_possible_truncation)]
    #[allow(clippy::cast_precision_loss)]
    #[allow(clippy::cast_sign_loss)]
    pub fn isqrt(n: u32) -> u32 {
        (n as f64).sqrt() as u32
    }

    pub fn factorial(n: u32) -> Integer {
        let mut fact = Integer::new();
        fact.assign(1);
        let mut n0 = n;
        while n0 > 1 {
            fact *= n0;
            n0 -= 1;
        }
        fact
    }

    pub fn nth_triangular(n: usize) -> u32 {
        let tri = n * (n + 1) / 2;
        u32::try_from(tri).unwrap()
    }

    pub fn fibonacci() -> FibonacciIter {
        let f1 = Integer::from(0);
        let f2 = Integer::from(1);
        FibonacciIter { f1, f2 }
    }

    /// Find the non-repeating and repeating portions of a floating-point
    /// number `n/d`.
    ///
    /// # Returns
    ///
    /// 1. non-repeating portion
    /// 2. repeating ("repetend") portion
    ///
    /// # Examples
    ///
    /// ```
    /// # use euler_rust::math::Math;
    /// // 1/28 = 0.03(571428)
    /// let (nonrep, rep) = Math::repetend(1, 28);
    /// assert_eq!("003", nonrep);
    /// assert_eq!("571428", rep);
    /// ```
    ///
    /// # See Also
    ///
    /// - Wikipedia article: [Repeating decimal](https://en.wikipedia.org/wiki/Repeating_decimal)
    pub fn repetend(n: u32, d: u32) -> (String, String) {
        let mut digits: String = String::new();
        let mut r: u32 = n;
        let mut seen: HashMap<u32, usize> = HashMap::new();
        // this is long-division, looking for a repeated remainder:
        while r > 0 {
            let m = r / d;
            r = r - d * m;
            digits = format!("{}{}", digits, m.to_string());
            if seen.contains_key(&r) {
                // repeats
                return (
                    String::from(&digits[0..seen[&r]]),
                    String::from(&digits[seen[&r]..]),
                )
            }
            seen.insert(r, digits.len());
            r *= 10;
        }
        // doesn't repeat
        (digits, String::new())
    }
}

#[cfg(test)]
mod tests {
    use crate::primes::Primes;
    use super::*;

    #[test]
    fn test_max_n_isqrt_64() {
        let ns = Math::isqrt_64(MAX_52_BIT);
        assert_eq!(67_108_863, ns);
    }

    #[test]
    #[should_panic]
    fn test_big_n_isqrt_64() {
        Math::isqrt_64(MAX_52_BIT + 1);
    }

    #[test]
    fn test_max_n_isqrt() {
        let ns = Math::isqrt(std::u32::MAX);
        assert_eq!(65535, ns);
    }

    #[test]
    fn test_factorial() {
        assert_eq!(3628800, Math::factorial(10));
    }

    #[test]
    fn test_nth_triangular() {
        assert_eq!(1, Math::nth_triangular(1));
        assert_eq!(3, Math::nth_triangular(2));
        assert_eq!(21, Math::nth_triangular(6));
    }

    #[test]
    fn test_fibonacci() {
        let i = Math::fibonacci();
        let act: Vec<u32> = i.take(7).map(|n| u32::try_from(n).unwrap()).collect();
        assert_eq!(vec![1, 1, 2, 3, 5, 8, 13], act);
    }

    #[test]
    fn test_repetend_1_6() {
        let (nonrep, rep) = Math::repetend(1, 6);
        assert_eq!("01", nonrep);
        assert_eq!("6", rep);
    }

    #[test]
    fn test_repetend_1_7() {
        let (nonrep, rep) = Math::repetend(1, 7);
        assert_eq!("0", nonrep);
        assert_eq!("142857", rep);
    }

    #[test]
    fn test_repetend_1_8() {
        let (nonrep, rep) = Math::repetend(1, 8);
        assert_eq!("0125", nonrep);
        assert_eq!("", rep);
    }

    #[test]
    fn test_repetend_355_113() {
        let (nonrep, rep) = Math::repetend(355, 113);
        assert_eq!("3", nonrep);
        assert_eq!("1415929203539823008849557522123893805309734513274336283185840707964601769911504424778761061946902654867256637168", rep);
        assert_eq!(112, rep.len());
    }

    #[test]
    fn test_intfraction_reduce_simple() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let int_f = IntFraction::new(4, 8).reduce(&factorizer);
        assert_eq!(IntFraction::new(1, 2), int_f);
    }

    #[test]
    fn test_intfraction_reduce_gcf() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        //     2^3 * 3 * 5  /  2^2 * 5 * 7
        // 2^2 * 2 * 3 * 5  /  2^2 * 5 * 7
        //           2 * 3  /  7
        let int_f = IntFraction::new(120, 140).reduce(&factorizer);
        assert_eq!(IntFraction::new(6, 7), int_f);
    }

    #[test]
    fn test_intfraction_reduce_cant() {
        let primes = Primes::new(120).unwrap();
        let factorizer = NaiveFactorizer::new(&primes).unwrap();
        let int_f = IntFraction::new(15, 14).reduce(&factorizer);
        assert_eq!(IntFraction::new(15, 14), int_f);
    }

    #[test]
    fn test_intfraction_equals() {
        let first_t = IntFraction::new(49, 98);
        let first_f = IntFraction::new(47, 78);
        let second = IntFraction::new(4, 8);
        assert_eq!(true, first_t.equals(second));
        assert_eq!(false, first_f.equals(second));
    }
}
