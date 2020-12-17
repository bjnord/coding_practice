use crate::rule::Rule;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, PartialEq)]
pub struct Ticket {
    values: Vec<u32>,
}

impl FromStr for Ticket {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let s_values: Vec<&str> = line.split(',').collect();
        let values: Vec<u32> = s_values.iter().map(|v| v.parse().unwrap()).collect();
        Ok(Self { values })
    }
}

impl Ticket {
    /// Return ticket values.
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

    /// Does this ticket have all valid values, according to the given
    /// `rules`?
    pub fn is_valid(&self, rules: &Vec<Rule>) -> bool {
        self.values
            .iter()
            .all(|&value|
                rules
                    .iter()
                    .any(|rule| rule.allows(value))
            )
    }

    /// Return sum of all invalid values of this ticket, according to the
    /// given `rules`.
    pub fn invalid_value_sum(&self, rules: &Vec<Rule>) -> u32 {
        self.values
            .iter()
            .map(|&value|
                match rules.iter().any(|rule| rule.allows(value)) {
                    true => 0,
                    false => value,
                }
            )
            .sum()
    }
}

#[cfg(test)]
mod tests {
    use crate::rule::Rule;
    use super::*;

    #[test]
    fn test_from_input() {
        let ticket = Ticket::from_input("59,101,191,149,167,197,199,137,163,131\n").unwrap();
        assert_eq!(1, ticket.len());
        assert_eq!(10, ticket[0].values().len());
    }

    #[test]
    fn test_is_valid() {
        let rules = Rule::from_input("class: 1-2 or 4-19\nrow: 1-5 or 8-19\nseat: 1-13 or 16-19\n").unwrap();
        let tickets = Ticket::from_input("3,6,7,14,15\n3,6,7,20,15\n3,0,7,14,15\n").unwrap();
        assert_eq!(true, tickets[0].is_valid(&rules));
        assert_eq!(false, tickets[1].is_valid(&rules));
        assert_eq!(false, tickets[2].is_valid(&rules));
    }

    #[test]
    fn test_invalid_value_sum() {
        let rules = Rule::from_input("class: 1-2 or 4-19\nrow: 1-5 or 8-19\nseat: 1-13 or 16-19\n").unwrap();
        let tickets = Ticket::from_input("3,6,7,14,15\n3,6,7,20,15\n3,0,7,14,15\n").unwrap();
        assert_eq!(0, tickets[0].invalid_value_sum(&rules));
        assert_eq!(20, tickets[1].invalid_value_sum(&rules));
        assert_eq!(0, tickets[2].invalid_value_sum(&rules));
    }
}
