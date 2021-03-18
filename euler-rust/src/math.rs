/// General math functions

use rug::{Assign, Float, Integer};
use std::convert::TryFrom;

const MAX_52_BIT: u64 = 4_503_599_627_370_495;

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
    /// number `f`. **NOTE** that `f` should be initialized with sufficient
    /// precision to detect the repetition, or you will get an incorrect
    /// result.
    ///
    /// # Returns
    ///
    /// 1. sign (`true` for negative, `false` for positive)
    /// 2. non-repeating portion
    /// 3. repeating ("repetend") portion
    /// 4. exponent
    ///
    /// # Examples
    ///
    /// ```
    /// # use euler_rust::math::Math;
    /// # use rug::Float;
    /// // 1/28 = 0.03(571428)
    /// let num = Float::with_val(128, 1.0);
    /// let denom = Float::with_val(128, 28.0);
    /// let f = num / denom;
    /// let (sign, nonrep, rep, exp) = Math::decimal_cycle(&f);
    /// assert_eq!("3", nonrep);
    /// assert_eq!("571428", rep);
    /// assert_eq!(false, sign);
    /// assert_eq!(Some(-1), exp);
    /// ```
    //
    // ref.: <https://en.wikipedia.org/wiki/Repeating_decimal>
    pub fn decimal_cycle(f: &Float) -> (bool, String, String, Option<i32>) {
        // the last N digits can be incorrect due to precision
        const FUDGE: usize = 3;
        // extract sign, digit string, and exponent:
        let (sign, s, exp) = f.to_sign_string_exp(10, None);
        //eprintln!("for f={} s='{}' (len={})", f, s, s.len());
        // determine the bounds of the repetend:
        let mut rep_i: usize = 0;
        let mut rep_len: usize = 0;
        for i in 0..s.len() {
            let ich = s.chars().nth(i).unwrap();
            for j in i+1..s.len() {
                if s.chars().nth(j).unwrap() == ich {
                    let mut len = j - i;
                    if j + len > s.len() {
                        //eprintln!("  ...OVERFLOW i={} ich='{}' vs j={} jstr='{}' len={}", i, ich, j, &s[j..], len);
                        break;
                    }
                    let left = &s[i..j];
                    let right = &s[j..j+len];
                    if left == right {
                        //eprintln!("  ...MATCH i={} ich='{}' vs j={} jstr='{}' len={} left='{}' right='{}'", i, ich, j, &s[j..], len, left, right);
                        let mut k = j + len;
                        while k + len < s.len() - FUDGE {
                            let rpt = &s[k..k+len];
                            if rpt != left {
                                //eprintln!("    ...but MISMATCH i={} ich='{}' left='{}' vs k={} kstr='{}' rpt='{}'", i, ich, left, k, &s[k..], rpt); len = 0;
                                len = 0;
                                break;
                            }
                            k += len;
                        }
                        if len == 0 {
                            continue;  // from MISMATCH
                        }
                        //eprintln!("    ...and it repeats to end");
                        rep_i = i;
                        rep_len = len;
                    }
                }
                if rep_len > 0 {
                    break;
                }
            }
            if rep_len > 0 {
                break;
            }
        }
        let mut nonrep: String = String::from(&s);
        let mut rep: String = String::new();
        if rep_len > 0 {
            nonrep = String::from(&s[0..rep_i]);
            rep = String::from(&s[rep_i..rep_i+rep_len]);
            if rep == "0" {
                rep = String::new();
            }
        }
        //eprintln!("  rep_i={} rep_len={} nonrep={} rep={}", rep_i, rep_len, nonrep, rep);
        (sign, nonrep, rep, exp)
    }
}

#[cfg(test)]
mod tests {
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
    fn test_decimal_cycle_1_6() {
        let num = Float::with_val(128, 1.0);
        let denom = Float::with_val(128, 6.0);
        let f = num / denom;
        let (sign, nonrep, rep, exp) = Math::decimal_cycle(&f);
        assert_eq!("1", nonrep);
        assert_eq!("6", rep);
        assert_eq!(false, sign);
        assert_eq!(Some(0), exp);
    }

    #[test]
    fn test_decimal_cycle_1_7() {
        let num = Float::with_val(128, 1.0);
        let denom = Float::with_val(128, 7.0);
        let f = num / denom;
        let (sign, nonrep, rep, exp) = Math::decimal_cycle(&f);
        assert_eq!("", nonrep);
        assert_eq!("142857", rep);
        assert_eq!(false, sign);
        assert_eq!(Some(0), exp);
    }

    #[test]
    fn test_decimal_cycle_minus_1_8() {
        let num = Float::with_val(128, -1.0);
        let denom = Float::with_val(128, 8.0);
        let f = num / denom;
        let (sign, nonrep, rep, exp) = Math::decimal_cycle(&f);
        assert_eq!("125", nonrep);
        assert_eq!("", rep);
        assert_eq!(true, sign);
        assert_eq!(Some(0), exp);
    }

    #[test]
    fn test_decimal_cycle_355_113() {
        let num = Float::with_val(1536, 355.0);
        let denom = Float::with_val(1536, 113.0);
        let f = num / denom;
        let (sign, nonrep, rep, exp) = Math::decimal_cycle(&f);
        assert_eq!("3", nonrep);
        assert_eq!("1415929203539823008849557522123893805309734513274336283185840707964601769911504424778761061946902654867256637168", rep);
        assert_eq!(112, rep.len());
        assert_eq!(false, sign);
        assert_eq!(Some(1), exp);
    }
}
