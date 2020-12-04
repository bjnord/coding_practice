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
        let mut fields: Vec<Field> = vec![];
        for field in line.split_whitespace() {
            if let Some((name, value)) = field.split(":").collect_tuple() {
                fields.push(Field{name: String::from(name), value: String::from(value)});
            } else {
                let e = format!("invalid input field format [{}]", field);
                return Err(Box::new(io::Error::new(ErrorKind::InvalidInput, e)));
            };
        }
        let valid = Passport::validate(&fields);
        Ok(Self{fields, valid})
    }
}

impl Passport {
    /// Is this passport valid?
    #[must_use]
    pub fn is_valid(&self) -> bool {
        self.valid
    }

    // Are passport fields valid and complete?
    #[must_use]
    fn validate(fields: &Vec<Field>) -> bool {
        // per puzzle, ignore cid
        let required = vec!["ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt"];
        let mut required: HashSet<&str> = required.into_iter().collect();
        for field in fields {
            if required.contains(&field.name[..]) {
                required.remove(&field.name[..]);
            }
        }
        required.is_empty()
    }
}
