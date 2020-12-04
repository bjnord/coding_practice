#![warn(clippy::pedantic)]

use itertools::Itertools;
use std::collections::HashSet;
use std::error;
use std::io::{self, ErrorKind};
use std::str::FromStr;

pub struct Field {
    name: String,
    value: String,
}

pub struct Passport {
    #[allow(dead_code)]
    fields: Vec<Field>,
    valid: bool,
}

impl FromStr for Passport {
    type Err = Box<dyn error::Error>;

    fn from_str(block: &str) -> Result<Self, Self::Err> {
        let line = block.replace("\n", " ");
        let mut names = HashSet::new();
        let mut fields: Vec<Field> = vec![];
        for field in line.split_whitespace() {
            if let Some((name, value)) = field.split(":").collect_tuple() {
                names.insert(name);
                fields.push(Field{name: String::from(name), value: String::from(value)});
            } else {
                let e = format!("invalid input field format [{}]", field);
                return Err(Box::new(io::Error::new(ErrorKind::InvalidInput, e)));
            };
        }
        Ok(Self{fields, valid: Passport::is_complete(&names)})
    }
}

impl Passport {
    /// Is this passport valid?
    #[must_use]
    pub fn is_valid(&self) -> bool {
        self.valid
    }

    // Is list of passport fields complete?
    fn is_complete(names: &HashSet<&str>) -> bool {
        // per puzzle, ignore cid
        let expects = vec!["ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt"];
        for expect in expects {
            if !names.contains(expect) {
                return false;
            }
        }
        true
    }
}
