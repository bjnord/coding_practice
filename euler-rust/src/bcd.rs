/// Binary Coded Decimal functions

use custom_error::custom_error;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub BCDError
    ValueOutOfRange = "value out of range",
}

pub struct DoubleDabbler {
    bits: Vec<u8>,
    digits: Vec<u8>,
}

// h/t <https://en.wikipedia.org/wiki/Double_dabble>
impl DoubleDabbler {
    /// Construct for the given value `n`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the given `n` value is invalid.
    pub fn new(n: u64) -> Result<DoubleDabbler> {
        let bits = Self::bits_from_value(n);
        let digits: Vec<u8> = vec![0; Self::n_digits(bits.len())];
        let mut dd = Self { bits, digits };
        dd.calculate();
        Ok(dd)
    }

    /// Construct for the value `2^p`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the given `p` power is invalid.
    pub fn from_power(p: usize) -> Result<DoubleDabbler> {
        let bits = Self::bits_from_power(p);
        let digits: Vec<u8> = vec![0; Self::n_digits(bits.len())];
        let mut dd = Self { bits, digits };
        dd.calculate();
        Ok(dd)
    }

    // Perform the double dabble algorithm, transforming `self.bits[]` into
    // the BCD vector `self.digits[]`.
    fn calculate(&mut self) {
        let n_bits: usize = self.bits.len();
        let n_digits: usize = self.digits.len();
        let mut n = 0;
        while n < n_bits {
            for di in 0..n_digits {
                if self.digits[di] >= 5 {
                    self.digits[di] += 3;
                }
            }
            let mut carry: u8 = self.bits[n_bits - n - 1];
            for di in 0..n_digits {
                let mut d = (self.digits[di] << 1) + carry;
                if d > 0xf {
                    d ^= 0x10;
                    carry = 1;
                } else {
                    carry = 0;
                }
                self.digits[di] = d;
            }
            n += 1;
        }
    }

    /// Return value as integer.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the value is too large to render as an
    /// integer.
    pub fn value(&self) -> Result<u64> {
        if self.bits.len() > 64 {
            return Err(BCDError::ValueOutOfRange.into());
        }
        let mut v = 0_u64;
        for &d in self.digits.iter().rev() {
            v = v * 10 + (d as u64);
        }
        Ok(v)
    }

    /// Return value as BCD digits.
    /// `digits[0]` is the least-significant digit.
    pub fn digits(&self) -> Vec<u8> {
        self.digits.to_vec()
    }

    // Create a `Vec<u8>` bit vector from value `n`.
    // `bits[0]` is the LSB.
    fn bits_from_value(n: u64) -> Vec<u8> {
        let mut n0 = n;
        let mut bits: Vec<u8> = Vec::new();
        for i in 0..64 {
            match n0 & (0x1 << i) {
                0 => bits.push(0),
                b => {
                    bits.push(1);
                    n0 ^= b;
                },
            }
            if n0 == 0x0 {
                break;
            }
        }
        bits
    }

    // Create a `Vec<u8>` bit vector from value `2^p`.
    // `bits[0]` is the LSB.
    fn bits_from_power(p: usize) -> Vec<u8> {
        let mut bits: Vec<u8> = vec![0; p + 1];
        bits[p] = 0x1;
        bits
    }

    // How many BCD digits are required to hold a value `n_bits` long?
    fn n_digits(n_bits: usize) -> usize {
        // algorithm uses "ceil(n/3)" which is sometimes 1 more than needed
        // _e.g._ 16-bit 65,535 only needs 5 digits; formula gives 6
        (n_bits + 2) / 3
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_value() {
        let dabbler = DoubleDabbler::new(243).unwrap();
        assert_eq!(243, dabbler.value().unwrap());
    }

    #[test]
    fn test_value_2() {
        let dabbler = DoubleDabbler::new(65244).unwrap();
        assert_eq!(65244, dabbler.value().unwrap());
    }

    // TODO test value() with value out of range

    #[test]
    fn test_from_power_digits() {
        let dabbler = DoubleDabbler::from_power(8).unwrap();
        assert_eq!(vec![6, 5, 2], dabbler.digits());
    }

    #[test]
    fn test_from_power_digits_2() {
        let dabbler = DoubleDabbler::from_power(16).unwrap();
        assert_eq!(vec![6, 3, 5, 5, 6, 0], dabbler.digits());
    }

    #[test]
    fn test_bits_from_value() {
        assert_eq!(vec![0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1], DoubleDabbler::bits_from_value(1202));
    }

    #[test]
    fn test_bits_from_power() {
        assert_eq!(vec![0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], DoubleDabbler::bits_from_power(10));
    }

    #[test]
    fn test_n_digits() {
        assert_eq!(1, DoubleDabbler::n_digits(1));
        assert_eq!(3, DoubleDabbler::n_digits(8));
        assert_eq!(3, DoubleDabbler::n_digits(9));
        assert_eq!(4, DoubleDabbler::n_digits(10));
        assert_eq!(6, DoubleDabbler::n_digits(17));
    }
}
