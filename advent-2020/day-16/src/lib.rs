mod rule;
mod ticket;

use crate::rule::Rule;
use crate::ticket::Ticket;
use std::collections::BTreeMap;
use std::error;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn error::Error>>;

#[derive(Debug)]
pub struct Puzzle {
    rules: Vec<Rule>,
    your_ticket: Ticket,
    nearby_tickets: Vec<Ticket>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct TicketField {
    pub name: String,
    pub value: u32,
}

#[derive(Debug, Clone)]
struct PuzzleError(String);

impl fmt::Display for PuzzleError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Puzzle error: {}", self.0)
    }
}

impl error::Error for PuzzleError {}

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
        if sections.len() < 2 {
            let e = format!("'your ticket:' divider not found");
            return Err(PuzzleError(e).into());
        }
        let rules = Rule::from_input(sections[0])?;
        let sections: Vec<&str> = sections[1].split("\n\nnearby tickets:\n").collect();
        if sections.len() < 2 {
            let e = format!("'nearby tickets:' divider not found");
            return Err(PuzzleError(e).into());
        }
        let your_tickets = Ticket::from_input(sections[0])?;
        if your_tickets.len() != 1 {
            let e = format!("found {} tickets in 'your ticket:' section", your_tickets.len());
            return Err(PuzzleError(e).into());
        }
        let your_ticket = your_tickets.into_iter().next().unwrap();
        let nearby_tickets = Ticket::from_input(sections[1])?;
        Ok(Self { rules, your_ticket, nearby_tickets })
    }

    /// Return nearby tickets with valid values.
    pub fn valid_nearby_tickets(&self) -> Vec<&Ticket> {
        self.nearby_tickets
            .iter()
            .filter(|ticket| ticket.is_valid(&self.rules))
            .collect()
    }

    /// Return "scanning error rate" for **invalid** nearby tickets.
    pub fn scanning_error_rate(&self) -> u32 {
        self.nearby_tickets
            .iter()
            .map(|ticket| ticket.invalid_value_sum(&self.rules))
            .sum()
    }

    /// Return fields (name/value pairs) from "your ticket".
    pub fn your_ticket_fields(&self) -> Vec<TicketField> {
        let n_fields = self.rules.len();
        let mut unidentified: BTreeMap<String, &Rule> = BTreeMap::new();
        for rule in self.rules.iter() {
            unidentified.insert(String::from(rule.name()), rule);
        }
        let mut identified: BTreeMap<usize, &Rule> = BTreeMap::new();
        while !unidentified.is_empty() {
            for i in 0..n_fields {
                if identified.contains_key(&i) {
                    continue;
                }
                // FIXME change self.rules.iter() to unidentified.[...]
                //       and then can skip the "is_unid" check
                let candidates: Vec<&Rule> = self.rules
                    .iter()
                    .filter(|rule| {
                        let is_unid = unidentified.contains_key(&String::from(rule.name()));
                        match is_unid {
                            true => {
                                self.valid_nearby_tickets()
                                    .iter()
                                    .all(|ticket| rule.allows(ticket.values()[i]))
                            },
                            false => {
                                false
                            },
                        }
                    })
                    .collect();
                match candidates.len() {
                    0 => panic!("no rule candidates for column {}", i),
                    1 => {
                        let rule = candidates[0];
                        identified.insert(i, &rule);
                        unidentified.remove(&String::from(rule.name()));
                    },
                    _ => { },
                }
            }
        }
        identified.keys()
            .map(|k| TicketField {
                name: String::from(identified[k].name()),
                value: self.your_ticket.values()[*k],
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use crate::rule::RuleRange;
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
    fn test_read_from_file_bad_file_2() {
        let puzzle = Puzzle::read_from_file("input/bad2.txt");
        assert!(puzzle.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file_3() {
        let puzzle = Puzzle::read_from_file("input/bad3.txt");
        assert!(puzzle.is_err());
    }

    #[test]
    fn test_valid_nearby_tickets() {
        let puzzle = Puzzle::read_from_file("input/example1.txt").unwrap();
        let tickets = puzzle.valid_nearby_tickets();
        assert_eq!(1, tickets.len());
        assert_eq!(vec![7, 3, 47], tickets[0].values());
    }

    #[test]
    fn test_scanning_error_rate() {
        let puzzle = Puzzle::read_from_file("input/example1.txt").unwrap();
        assert_eq!(71, puzzle.scanning_error_rate());
    }

    #[test]
    fn test_your_ticket_fields() {
        let puzzle = Puzzle::read_from_file("input/example2.txt").unwrap();
        assert_eq!(vec![
                TicketField { name: String::from("row"), value: 11 },
                TicketField { name: String::from("class"), value: 12 },
                TicketField { name: String::from("seat"), value: 13 },
            ], puzzle.your_ticket_fields());
    }
}
