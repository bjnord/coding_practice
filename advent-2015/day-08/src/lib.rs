use regex::Regex;
use lazy_static::lazy_static;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct QuotedString {
    n_chars: usize,
    length: usize,
}

impl FromStr for QuotedString {
    type Err = regex::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        lazy_static! {
            static ref QUOTED_STRING_RE: Regex = Regex::new("^\"(.*)\"$").unwrap();
        }
        if QUOTED_STRING_RE.is_match(s) {
            let capture = QUOTED_STRING_RE.captures_iter(s).next().unwrap();
            let n_chars = capture[1].len() + 2;
            let decoded_s = QuotedString::decode(&capture[1]);
            let length = decoded_s.len();
            Ok(Self { n_chars, length })
        } else {
            let e_str = format!("invalid string '{}'", s);
            Err(Self::Err::Syntax(e_str))
        }
    }
}

impl QuotedString {
    fn decode(s: &str) -> String {
        lazy_static! {
            static ref HEX_CHAR_RE: Regex = Regex::new("\\\\x(..)").unwrap();
        }
        let mut ds = s.to_string();
        while HEX_CHAR_RE.is_match(ds.as_str()) {
            let capture = HEX_CHAR_RE.captures_iter(ds.as_str()).next().unwrap();
            let cap_s = String::from("\\x") + &capture[1];
            ds = ds.replace(cap_s.as_str(), "\x1a");
        }
        ds = ds.replace("\\\"", "\"");
        ds = ds.replace("\\\\", "\\");
        ds
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // "" is 2 characters of code (the two double quotes), but the string contains zero characters.
    #[test]
    fn test_parse_ex1() {
        let qs: QuotedString = "\"\"".parse().unwrap();
        assert_eq!(2, qs.n_chars, "ex1 n_chars");
        assert_eq!(0, qs.length, "ex1 length");
    }

    // "abc" is 5 characters of code, but 3 characters in the string data.
    #[test]
    fn test_parse_ex2() {
        let qs: QuotedString = "\"abc\"".parse().unwrap();
        assert_eq!(5, qs.n_chars, "ex2 n_chars");
        assert_eq!(3, qs.length, "ex2 length");
    }

    // "aaa\"aaa" is 10 characters of code, but the string itself contains six "a" characters and a
    // single, escaped quote character, for a total of 7 characters in the string data.
    #[test]
    fn test_parse_ex3() {
        let qs: QuotedString = "\"aaa\\\"aaa\"".parse().unwrap();
        assert_eq!(10, qs.n_chars, "ex3 n_chars");
        assert_eq!(7, qs.length, "ex3 length");
    }

    // "\x27" is 6 characters of code, but the string itself contains just one - an apostrophe ('),
    // escaped using hexadecimal notation.
    #[test]
    fn test_parse_ex4() {
        let qs: QuotedString = "\"\\x27\"".parse().unwrap();
        assert_eq!(6, qs.n_chars, "ex4 n_chars");
        assert_eq!(1, qs.length, "ex4 length");
    }

    #[test]
    fn test_parse_invalid() {
        let e = "\"123".parse::<QuotedString>().unwrap_err();
        assert_eq!("invalid string '\"123'", e.to_string());
    }
}
