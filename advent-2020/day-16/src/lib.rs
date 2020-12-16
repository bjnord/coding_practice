use itertools::Itertools;
use std::error;
use std::fmt;
use std::fs;
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
    ranges: Vec<RuleRange>,
}

impl FromStr for Rule {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let tokens: Vec<&str> = line.split(": ").collect();
        let value = match tokens.get(1) {
            Some(v) => v,
            None => {
                let e = format!("invalid rule [{}]", line);
                return Err(RuleError(e).into());
            },
        };
        let ranges_result: Result<Vec<RuleRange>> = value.split(" or ")
            .map(Rule::parse_range)
            .collect();
        match ranges_result {
            Err(e) => Err(e),
            Ok(ranges) => Ok(Self { ranges }),
        }
    }
}

impl Rule {
    /// Return rule ranges.
    #[cfg(test)]
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
}

#[derive(Debug, Clone, PartialEq)]
pub struct Ticket {
    values: Vec<u32>,
}

impl FromStr for Ticket {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let s_values: Vec<&str> = line.split(',').collect();
        let values: Vec<u32> = s_values.iter().map(|v| v.parse().unwrap()).collect();
        Ok(Self { values })
    }
}

impl Ticket {
    /// Return ticket values.
    #[cfg(test)]
    #[must_use]
    pub fn values(&self) -> Vec<u32> {
        self.values.clone()
    }

    /// Read tickets from `input` (list of lines).
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid ticket format.
    pub fn from_input(input: &str) -> Result<Vec<Ticket>> {
        input.lines().map(str::parse).collect()
    }
}

#[derive(Debug)]
pub struct Puzzle {
    rules: Vec<Rule>,
    nearby_tickets: Vec<Ticket>,
}

impl Puzzle {
    /// Return list of nearby tickets.
    #[cfg(test)]
    #[must_use]
    pub fn nearby_tickets(&self) -> Vec<Ticket> {
        self.nearby_tickets.clone()
    }

    /// Construct by reading rule and ticket data from path.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<Puzzle> {
        let s: String = fs::read_to_string(path)?;
        let sections: Vec<&str> = s.split("\n\nyour ticket:\n").collect();
        let rules = Rule::from_input(sections[0])?;
        let subsections: Vec<&str> = sections[1].split("\n\nnearby tickets:\n").collect();
        let nearby_tickets = Ticket::from_input(subsections[1])?;
        Ok(Self { rules, nearby_tickets })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let puzzle = Puzzle::read_from_file("input/example1.txt").unwrap();
        assert_eq!(3, puzzle.rules.len());
        assert_eq!(vec![RuleRange { start: 13, end: 40 }, RuleRange { start: 45, end: 50 }],
            puzzle.rules[2].ranges());
        assert_eq!(4, puzzle.nearby_tickets.len());
        assert_eq!(vec![38, 6, 12], puzzle.nearby_tickets[3].values());
    }

    #[test]
    fn test_read_from_file_no_file() {
        let puzzle = Puzzle::read_from_file("input/example99.txt");
        assert!(puzzle.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let puzzle = Puzzle::read_from_file("input/bad1.txt");
        assert!(puzzle.is_err());
    }

    #[test]
    fn test_parse_rule() {
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
