#[derive(Debug, Clone, Eq, PartialEq)]
pub struct AdventCoin {
    pub key: String,
}

impl AdventCoin {
    /// Construct a new coin with the given secret `key`.
    #[must_use]
    pub fn new(key: &str) -> Self {
        Self {
            key: key.to_string(),
        }
    }

    /// Calculate the MD5 hash for the given `number`.
    ///
    /// # Examples
    /// ```
    /// # use day_04::AdventCoin;
    /// let coin = AdventCoin::new("abcdef");
    /// assert_eq!("000001dbbfa3a5c83a2d506429c7b00e", coin.hash(609043));
    /// ```
    #[must_use]
    pub fn hash(&self, number: u64) -> String {
        let s = format!("{}{}", self.key, number);
        let digest = md5::compute(s.as_bytes());
        format!("{:x}", digest)
    }

    /// Find the lowest positive number that produces an MD5 hash starting with the given number of
    /// leading zeros.
    ///
    /// # Examples
    /// ```
    /// # use day_04::AdventCoin;
    /// let coin = AdventCoin::new("abcdef");
    /// assert_eq!(3337, coin.number(3));
    /// ```
    #[must_use]
    pub fn number(&self, n_zeros: usize) -> u64 {
        let mut n: u64 = 1;
        loop {
            for (i, ch) in self.hash(n).chars().enumerate() {
                match ch {
                    '0' => {
                        if i >= n_zeros - 1 {
                            return n;
                        }
                    }
                    _ => {
                        break;
                    }
                };
            }
            n += 1;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_coin_hash() {
        let coin = AdventCoin::new("pqrstuv");
        assert_eq!("000006136ef2ff3b291c85725f17325c", coin.hash(1048970));
    }
}
