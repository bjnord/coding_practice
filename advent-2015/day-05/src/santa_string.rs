use fancy_regex::Regex;
use lazy_static::lazy_static;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct SantaString {
    n_vowels: u32,
    has_double: bool,
    has_naughty: bool,
}

impl FromStr for SantaString {
    type Err = std::string::ParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let n_vowels: u32 = s
            .chars()
            .map(|ch| u32::from(SantaString::is_vowel(ch)))
            .sum();
        lazy_static! {
            static ref DOUBLE_RE: Regex = Regex::new(r"(\w)\1").unwrap();
            static ref NAUGHTY_RE: Regex = Regex::new(r"(?:ab|cd|pq|xy)").unwrap();
        }
        let has_double = DOUBLE_RE.is_match(s).unwrap();
        let has_naughty = NAUGHTY_RE.is_match(s).unwrap();
        Ok(Self {
            n_vowels,
            has_double,
            has_naughty,
        })
    }
}

impl SantaString {
    /// Is this a nice string?
    ///
    /// A nice string is one with all of the following properties:
    ///
    /// - It contains at least three vowels (`aeiou` only), like `aei`,
    ///   `xazegov`, or `aeiouaeiouaeiou`.
    /// - It contains at least one letter that appears twice in a row, like
    ///   `xx`, `abcdde` (`dd`), or `aabbccdd` (`aa`, `bb`, `cc`, or `dd`).
    /// - It does not contain the strings `ab`, `cd`, `pq`, or `xy`, even if
    ///   they are part of one of the other requirements.
    ///
    /// # Examples
    /// ```
    /// # use day_05::santa_string::SantaString;
    /// let ss: SantaString = "aaa".parse().unwrap();
    /// assert_eq!(true, ss.is_nice());
    /// ```
    #[must_use]
    pub fn is_nice(&self) -> bool {
        self.n_vowels >= 3 && self.has_double && !self.has_naughty
    }

    // Is the given character a vowel?
    fn is_vowel(ch: char) -> bool {
        ch == 'a' || ch == 'e' || ch == 'i' || ch == 'o' || ch == 'u'
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ugknbfddgicrmopn is nice because it has at least three vowels
    // (u...i...o...), a double letter (...dd...), and none of the
    // disallowed substrings.
    #[test]
    fn test_package_parse_ex1() {
        let ss: SantaString = "ugknbfddgicrmopn".parse().unwrap();
        assert_eq!(3, ss.n_vowels, "ex1 n_vowels");
        assert_eq!(true, ss.has_double, "ex1 has_double");
        assert_eq!(false, ss.has_naughty, "ex1 has_naughty");
        assert_eq!(true, ss.is_nice(), "ex1 is_nice");
    }

    // jchzalrnumimnmhp is naughty because it has no double letter.
    #[test]
    fn test_package_parse_ex3() {
        let ss: SantaString = "jchzalrnumimnmhp".parse().unwrap();
        assert_eq!(3, ss.n_vowels, "ex3 n_vowels");
        assert_eq!(false, ss.has_double, "ex3 has_double");
        assert_eq!(false, ss.has_naughty, "ex3 has_naughty");
        assert_eq!(false, ss.is_nice(), "ex3 is_nice");
    }

    // haegwjzuvuyypxyu is naughty because it contains the string xy.
    #[test]
    fn test_package_parse_ex4() {
        let ss: SantaString = "haegwjzuvuyypxyu".parse().unwrap();
        assert_eq!(5, ss.n_vowels, "ex4 n_vowels");
        assert_eq!(true, ss.has_double, "ex4 has_double");
        assert_eq!(true, ss.has_naughty, "ex4 has_naughty");
        assert_eq!(false, ss.is_nice(), "ex4 is_nice");
    }

    // dvszwmarrgswjxmb is naughty because it contains only one vowel.
    #[test]
    fn test_package_parse_ex5() {
        let ss: SantaString = "dvszwmarrgswjxmb".parse().unwrap();
        assert_eq!(1, ss.n_vowels, "ex5 n_vowels");
        assert_eq!(true, ss.has_double, "ex5 has_double");
        assert_eq!(false, ss.has_naughty, "ex5 has_naughty");
        assert_eq!(false, ss.is_nice(), "ex5 is_nice");
    }
}
