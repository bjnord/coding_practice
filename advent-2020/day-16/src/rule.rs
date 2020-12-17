use itertools::Itertools;
use std::error;
use std::fmt;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct RuleRangeError(String);

impl fmt::Display for RuleRangeError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Rule range error: {}", self.0)
    }
}

impl error::Error for RuleRangeError {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RuleRange {
    pub start: u32,
    pub end: u32,
}

#[derive(Debug, Clone)]
struct RuleError(String);

impl fmt::Display for RuleError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Rule error: {}", self.0)
    }
}

impl error::Error for RuleError {}

#[derive(Debug, Clone, PartialEq)]
pub struct Rule {
    name: String,
    ranges: Vec<RuleRange>,
}

impl FromStr for Rule {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let tokens: Vec<&str> = line.split(": ").collect();
        if tokens.len() != 2 {
            let e = format!("invalid rule [{}]", line);
            return Err(RuleError(e).into());
        }
        let name = String::from(tokens[0]);
        let value = tokens[1];
        let ranges_result: Result<Vec<RuleRange>> = value.split(" or ")
            .map(Rule::parse_range)
            .collect();
        match ranges_result {
            Err(e) => Err(e),
            Ok(ranges) => Ok(Self { name, ranges }),
        }
    }
}

impl Rule {
    /// Return rule name.
    #[must_use]
    pub fn name(&self) -> &str {
        &self.name[..]
    }

    /// Return rule ranges.
    #[must_use]
    pub fn ranges(&self) -> Vec<RuleRange> {
        self.ranges.clone()
    }

    // FIXME should be a FromStr on RuleRange
    pub fn parse_range(range: &str) -> Result<RuleRange> {
        let range_bounds: Vec<u32> = range.split('-')
            .map(|ns| ns.parse::<u32>().unwrap())
            .collect();
        if range_bounds.len() != 2 {
            let e = format!("invalid range [{}]", range);
            return Err(RuleRangeError(e).into());
        }
        match range_bounds.iter().next_tuple() {
            Some((&start, &end)) => Ok(RuleRange { start, end }),
            _ => {
                let e = format!("invalid range [{}]", range);
                return Err(RuleRangeError(e).into());
            },
        }
    }

    /// Read rules from `input` (list of lines).
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid rule format.
    pub fn from_input(input: &str) -> Result<Vec<Rule>> {
        input.lines().map(str::parse).collect()
    }

    /// Is `value` found in any of this rule's ranges?
    pub fn allows(&self, value: u32) -> bool {
        self.ranges
            .iter()
            .any(|range| value >= range.start && value <= range.end )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_rule_name() {
        assert_eq!("cummerbund",
            "cummerbund: 38-40 or 42-44".parse::<Rule>().unwrap().name);
    }

    #[test]
    fn test_parse_rule_ranges() {
        assert_eq!(vec![RuleRange { start: 1, end: 3 }, RuleRange { start: 5, end: 7 }],
            "class: 1-3 or 5-7".parse::<Rule>().unwrap().ranges());
        assert_eq!(vec![RuleRange { start: 6, end: 11 }, RuleRange { start: 33, end: 44 }],
            "row: 6-11 or 33-44".parse::<Rule>().unwrap().ranges());
        assert_eq!(vec![RuleRange { start: 13, end: 40 }, RuleRange { start: 45, end: 50 }],
            "seat: 13-40 or 45-50".parse::<Rule>().unwrap().ranges());
    }

    #[test]
    fn test_parse_rule_bad() {
        assert!("class:".parse::<Rule>().is_err());
        assert!("class: 1-3: 5-7".parse::<Rule>().is_err());
    }

    #[test]
    fn test_parse_range() {
        assert_eq!(RuleRange { start: 1, end: 3 }, Rule::parse_range("1-3").unwrap());
        assert_eq!(RuleRange { start: 5, end: 7 }, Rule::parse_range("5-7").unwrap());
    }

    #[test]
    fn test_parse_range_bad() {
        assert!(Rule::parse_range("1").is_err());
        assert!(Rule::parse_range("1-3-5").is_err());
    }
}
