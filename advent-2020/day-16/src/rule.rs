use std::fmt;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RuleRange {
    pub start: u32,
    pub end: u32,
}

impl FromStr for RuleRange {
    type Err = Box<dyn std::error::Error>;

    fn from_str(range: &str) -> Result<Self> {
        let (start, end) = scan_fmt!(range, "{d}-{d}", u32, u32)?;
        Ok(RuleRange { start, end })
    }
}

#[derive(Debug, Clone)]
struct RuleError(String);

impl fmt::Display for RuleError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Rule error: {}", self.0)
    }
}

impl std::error::Error for RuleError {}

#[derive(Debug, Clone, PartialEq)]
pub struct Rule {
    name: String,
    ranges: Vec<RuleRange>,
}

impl FromStr for Rule {
    type Err = Box<dyn std::error::Error>;

    // class: 1-3 or 5-7
    fn from_str(line: &str) -> Result<Self> {
        let mut i = line.split(": ");
        let name = i.next().unwrap();
        let ranges = i.next().ok_or_else(||
            Box::new(RuleError("rule ranges not found".to_string()))
        )?;
        let ranges: Vec<RuleRange> = ranges.split(" or ")
            .map(str::parse)
            .collect::<Result<Vec<RuleRange>>>()?;
        Ok(Self { name: String::from(name), ranges })
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
        assert!("class".parse::<Rule>().is_err());
        assert!("class: 1-".parse::<Rule>().is_err());
    }

    #[test]
    fn test_parse_rule_range() {
        assert_eq!(RuleRange { start: 1, end: 3 }, "1-3".parse::<RuleRange>().unwrap());
        assert_eq!(RuleRange { start: 5, end: 7 }, "5-7".parse::<RuleRange>().unwrap());
    }

    #[test]
    fn test_parse_rule_range_bad() {
        assert!("1-".parse::<RuleRange>().is_err());
    }

    #[test]
    fn test_allows() {
        let rule: Rule = "class: 1-3 or 5-7".parse().unwrap();
        assert_eq!(false, rule.allows(0));
        assert_eq!(true, rule.allows(1));
        assert_eq!(true, rule.allows(2));
        assert_eq!(true, rule.allows(3));
        assert_eq!(false, rule.allows(4));
        assert_eq!(true, rule.allows(5));
        assert_eq!(true, rule.allows(6));
        assert_eq!(true, rule.allows(7));
        assert_eq!(false, rule.allows(8));
    }
}
