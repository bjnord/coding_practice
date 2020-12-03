#![warn(clippy::pedantic)]

use std::io::{self, ErrorKind};
use lazy_static::lazy_static;
use regex::Regex;

#[derive(Debug, Clone, PartialEq)]
pub struct Password {
    first: usize,
    second: usize,
    letter: char,
    password: String,
}

impl Password {
    /// Construct by parsing input line.
    ///
    /// The line is in the form `F-S L: password` where
    /// - `F` is the first value (integer)
    /// - `S` is the second value (integer)
    /// - `L` is the letter (char)
    /// - `password` is the password (string)
    ///
    /// # Errors
    ///
    /// Returns `Err` if the line does not match the required format,
    /// or if the first value is greater than the second value.
    pub fn from_input_line(line: &str) -> Result<Self, io::Error> {
        lazy_static! {
            static ref RE: Regex = Regex::new(r"(?x)^
                (?P<first>\d+)-
                (?P<second>\d+)\s+
                (?P<letter>[a-z]):\s+
                (?P<password>[a-z]+)
                $").unwrap();
        }
        let cap = if let Some(cap) = RE.captures(line) { cap } else {
            let e = format!("invalid input line format [{}]", line);
            return Err(io::Error::new(ErrorKind::InvalidInput, e));
        };
        // all these unwrap() are safe, given a matching regex
        let first = String::from(cap.name("first").unwrap().as_str()).parse::<usize>().unwrap();
        let second = String::from(cap.name("second").unwrap().as_str()).parse::<usize>().unwrap();
        let letter = cap.name("letter").unwrap().as_str().chars().next().unwrap();
        let password = String::from(cap.name("password").unwrap().as_str());
        if first > second {
            let e = format!("first > second on input line [{}]", line);
            Err(io::Error::new(ErrorKind::InvalidInput, e))
        } else {
            Ok(Self{first, second, letter, password})
        }
    }

    /// Is this password valid according to the "min/max" policy?
    #[must_use]
    pub fn is_valid_minmax(&self) -> bool {
        let matches = self.password.matches(self.letter).count();
        matches >= self.first && matches <= self.second
    }

    /// Is this password valid according to the "1st/2nd" policy?
    #[must_use]
    pub fn is_valid_1st2nd(&self) -> bool {
        let first = self.password.chars().nth(self.first-1).unwrap_or('\0');
        let second = self.password.chars().nth(self.second-1).unwrap_or('\0');
        // to be valid, first OR second position must match, but not both
        (first == self.letter) ^ (second == self.letter)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_construct_password() {
        let password = Password::from_input_line("1-3 a: abcde").unwrap();
        assert_eq!(Password{first: 1, second: 3, letter: 'a', password: String::from("abcde")}, password);
    }

    #[test]
    fn test_construct_password2() {
        let password = Password::from_input_line("1-3 b: cdefg").unwrap();
        assert_eq!(Password{first: 1, second: 3, letter: 'b', password: String::from("cdefg")}, password);
    }

    #[test]
    fn test_construct_password3() {
        let password = Password::from_input_line("2-9 c: ccccccccc").unwrap();
        assert_eq!(Password{first: 2, second: 9, letter: 'c', password: String::from("ccccccccc")}, password);
    }

    #[test]
    fn test_construct_password_bad_format() {
        let password = Password::from_input_line("1-3 a = abcde");
        assert!(password.is_err());
    }

    #[test]
    fn test_construct_password_bad_values() {
        let password = Password::from_input_line("3-1 a: abcde");
        assert!(password.is_err());
    }

    #[test]
    fn test_valid_minmax_password() {
        let password = Password{first: 1, second: 3, letter: 'a', password: String::from("abcde")};
        assert!(password.is_valid_minmax());
        let password2 = Password{first: 2, second: 9, letter: 'c', password: String::from("ccccccccc")};
        assert!(password2.is_valid_minmax());
    }

    #[test]
    fn test_invalid_minmax_password() {
        let password = Password{first: 1, second: 3, letter: 'b', password: String::from("cdefg")};
        assert!(!password.is_valid_minmax());
    }

    #[test]
    fn test_valid_1st2nd_password() {
        let password = Password{first: 1, second: 3, letter: 'a', password: String::from("abcde")};
        assert!(password.is_valid_1st2nd());
    }

    #[test]
    fn test_invalid_1st2nd_password() {
        let password = Password{first: 1, second: 3, letter: 'b', password: String::from("cdefg")};
        assert!(!password.is_valid_1st2nd());
        let password2 = Password{first: 2, second: 9, letter: 'c', password: String::from("ccccccccc")};
        assert!(!password2.is_valid_1st2nd());
    }
}
