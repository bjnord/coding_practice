#![warn(clippy::pedantic)]

use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::error;
use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Rules> = result::Result<Rules, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct RuleError(String);

impl fmt::Display for RuleError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Rule error: {}", self.0)
    }
}

impl error::Error for RuleError {}

#[derive(Debug)]
pub struct Rules {
    can_contain: HashMap<String, Vec<String>>,
}

impl FromStr for Rules {
    type Err = Box<dyn error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        lazy_static! {
            // light red bags contain 1 bright white bag, 2 muted yellow bags.
            // dotted black bags contain no other bags.
            static ref LINE_RE: Regex = Regex::new(r"(?x)^
                (?P<container>.+)\s+bags\s+contain\s+
                (?P<contained>.+)\.
                $").unwrap();
            static ref BAG_RE: Regex = Regex::new(r"(?x)^
                (\d+|no)\s+
                (?P<color>.+)\s+bags?
                $").unwrap();
        }
        let mut can_contain: HashMap<String, Vec<String>> = HashMap::new();
        for line in input.lines() {
            let cap = if let Some(cap) = LINE_RE.captures(line) { cap } else {
                let e = format!("invalid input line format [{}]", line);
                return Err(RuleError(e).into());
            };
            // all these unwrap() are safe, given a matching regex
            let container_color = String::from(cap.name("container").unwrap().as_str());
            let contained_bags = String::from(cap.name("contained").unwrap().as_str());
            for bag in contained_bags.split(", ") {
                let capb = if let Some(capb) = BAG_RE.captures(bag) { capb } else {
                    let e = format!("invalid contained bag format [{}]", bag);
                    return Err(RuleError(e).into());
                };
                // this unwrap() is safe, given a matching regex
                let contained_color = String::from(capb.name("color").unwrap().as_str());
                if contained_color != "other" {
                    can_contain.entry(contained_color).or_insert(vec![]).push(container_color.clone());
                }
            }
        }
        Ok(Rules { can_contain })
    }
}

impl Rules {
    /// Return bag colors which can contain the provided bag color.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_07::Rules;
    /// let rules = Rules::read_from_file("input/example1.txt").unwrap();
    /// assert_eq!(4, rules.can_contain("shiny gold").len());
    /// ```
    #[must_use]
    pub fn can_contain(&self, color: &str) -> Vec<String> {
        let mut colors: Vec<String> = vec![];
        if let Some(rule) = self.can_contain.get(color) {
            for c_color in rule.to_vec() {
                colors.push(c_color.clone());
                colors.append(&mut self.can_contain(&c_color));
            }
            colors.sort();
            colors.dedup();
        }
        colors
    }

    /// Read rules from a file.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened.
    pub fn read_from_file(path: &str) -> Result<Rules> {
        let s: String = fs::read_to_string(path)?;
        s.parse()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file_bad_path() {
        let result = Rules::read_from_file("input/example99.txt");
        assert!(result.is_err());
    }
}
