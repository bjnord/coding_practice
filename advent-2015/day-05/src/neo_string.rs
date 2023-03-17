use fancy_regex::Regex;
use lazy_static::lazy_static;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct NeoString {
    has_double_pair: bool,
    has_sandwich: bool,
}

impl FromStr for NeoString {
    type Err = std::string::ParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        lazy_static! {
            static ref DOUBLE_PAIR_RE: Regex = Regex::new(r"(\w\w).*\1").unwrap();
            static ref SANDWICH_RE: Regex = Regex::new(r"(\w)\w\1").unwrap();
        }
        let has_double_pair = DOUBLE_PAIR_RE.is_match(s).unwrap();
        let has_sandwich = SANDWICH_RE.is_match(s).unwrap();
        Ok(Self {
            has_double_pair,
            has_sandwich,
        })
    }
}

impl NeoString {
    /// Is this a nice string?
    ///
    /// A nice string is one with all of the following properties:
    ///
    /// - It contains a pair of any two letters that appears at least
    ///   twice in the string without overlapping, like `xyxy` (`xy`) or
    ///   `aabcdefgaa` (`aa`), but not like `aaa` (`aa`, but it overlaps).
    /// - It contains at least one letter which repeats with exactly
    ///   one letter between them, like `xyx`, `abcdefeghi` (`efe`), or
    ///   even `aaa`.
    ///
    /// # Examples
    /// ```
    /// # use day_05::neo_string::NeoString;
    /// let ss: NeoString = "aaa".parse().unwrap();
    /// assert_eq!(false, ss.is_nice());
    /// ```
    #[must_use]
    pub fn is_nice(&self) -> bool {
        self.has_double_pair &&
            self.has_sandwich
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // `qjhvhtzxzqqjkmpb` is nice because is has a pair that appears
    // twice (`qj`) and a letter that repeats with exactly one letter
    // between them (`zxz`).
    #[test]
    fn test_package_parse_ex1() {
        let ns: NeoString = "qjhvhtzxzqqjkmpb".parse().unwrap();
        assert_eq!(true, ns.has_double_pair, "ex1 has_double_pair");
        assert_eq!(true, ns.has_sandwich, "ex1 has_sandwich");
        assert_eq!(true, ns.is_nice(), "ex1 is_nice");
    }

    // `xxyxx` is nice because it has a pair that appears twice and
    // a letter that repeats with one between, even though the letters
    // used by each rule overlap.
    #[test]
    fn test_package_parse_ex2() {
        let ns: NeoString = "xxyxx".parse().unwrap();
        assert_eq!(true, ns.has_double_pair, "ex2 has_double_pair");
        assert_eq!(true, ns.has_sandwich, "ex2 has_sandwich");
        assert_eq!(true, ns.is_nice(), "ex2 is_nice");
    }

    // `uurcxstgmygtbstg` is naughty because it has a pair (`tg`) but
    // no repeat with a single letter between them.
    #[test]
    fn test_package_parse_ex3() {
        let ns: NeoString = "uurcxstgmygtbstg".parse().unwrap();
        assert_eq!(true, ns.has_double_pair, "ex3 has_double_pair");
        assert_eq!(false, ns.has_sandwich, "ex3 has_sandwich");
        assert_eq!(false, ns.is_nice(), "ex3 is_nice");
    }

    // `ieodomkazucvgmuy` is naughty because it has a repeating letter
    // with one between (`odo`), but no pair that appears twice.
    #[test]
    fn test_package_parse_ex4() {
        let ns: NeoString = "ieodomkazucvgmuy".parse().unwrap();
        assert_eq!(false, ns.has_double_pair, "ex4 has_double_pair");
        assert_eq!(true, ns.has_sandwich, "ex4 has_sandwich");
        assert_eq!(false, ns.is_nice(), "ex4 is_nice");
    }
}
