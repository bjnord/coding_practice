use lazy_static::lazy_static;
use regex::Regex;
use std::fs;
use std::io::{self, ErrorKind};

#[derive(Debug, Clone)]
pub struct Employee {
    f_name: String,
    l_name: String,
    position: String,
    separation: String,  // TODO date type
}

impl Employee {
    pub fn from_tokens(tokens: Vec<&str>) -> Option<Employee> {
        lazy_static! {
            static ref LINE_RE: Regex = Regex::new(r"^---*$").unwrap();
        }
        let name = String::from(tokens[0].trim());
        if name == "First Name" || LINE_RE.is_match(&name) {
            return None;
        }
        let f_name = String::from(tokens[0].trim());
        let l_name = String::from(tokens[1].trim());
        let position = String::from(tokens[2].trim());
        let separation = String::from(tokens[3].trim());
        Some(Employee {f_name, l_name, position, separation})
    }
}

#[derive(PartialEq)]
pub enum RosterSort {
    Unsorted,
    Name,
    Position,
    Separation,
}

pub struct EmployeeRoster {
    roster: Vec<Employee>,
    sort_order: RosterSort,
}

impl EmployeeRoster {
    #[cfg(test)]
    fn for_tests() -> EmployeeRoster {
        EmployeeRoster::from_string("\n\
            First Name | Last Name  | Position          | Separation Date\n\
            -----------|------------|-------------------|----------------\n\
            John       | Johnson    | Manager           | 2016-12-31\n\
            Tou        | Xiong      | Software Engineer | 2016-10-05\n\
            Michaela   | Michaelson | District Manager  | 2015-12-19     \n\
            Jake       | Jacobson   | Programmer        |                \n\
            Jacquelyn  | Jackson    | DBA               | \n\
            Sally      | Weber      | Web Developer     | 2015-12-18\n\
            ").unwrap()
    }

    pub fn from_file(filename: &str) -> Result<EmployeeRoster, io::Error> {
        let input: String = fs::read_to_string(filename)?;
        EmployeeRoster::from_string(&input)
    }

    pub fn from_string(input: &str) -> Result<EmployeeRoster, io::Error> {
        let mut roster: Vec<Employee> = Vec::<Employee>::new();
        let lines: Vec<&str> = input.split("\n").collect();
        for line in lines {
            let tokens: Vec<&str> = line.split("|").collect();
            if tokens.len() == 1 && tokens[0].trim().is_empty() {
                continue;  // ignore blank lines
            } else if tokens.len() != 4 {
                let e = format!("line in unknown format (tokens={}): [{}]", tokens.len(), line);
                return Err(io::Error::new(ErrorKind::InvalidInput, e));
            }
            match Employee::from_tokens(tokens) {
                Some(emp) => roster.push(emp),
                None => (),
            }
        }
        Ok(EmployeeRoster {roster, sort_order: RosterSort::Unsorted})
    }

    pub fn len(&self) -> usize {
        self.roster.len()
    }

    pub fn find(&self, f_name: &str, l_name: &str) -> Option<&Employee> {
        self.roster.iter().find(|e| e.f_name == f_name && e.l_name == l_name)
    }

    pub fn sort_by(&mut self, order: RosterSort) {
        self.sort_order = order;
    }

    pub fn print(&self) {
        println!("\
            First Name | Last Name  | Position          | Separation Date\n\
            -----------|------------|-------------------|----------------");
        for emp in self.sorted_roster() {
            println!("{:<10} | {:<10} | {:<17} | {:<15}", emp.f_name, emp.l_name, emp.position, emp.separation);
        }
    }

    // private
    fn sorted_roster(&self) -> Vec<Employee> {
        let mut roster_copy = self.roster.to_vec();
        if self.sort_order != RosterSort::Unsorted {
            roster_copy.sort_by(|a, b| match self.sort_order {
                RosterSort::Unsorted => std::cmp::Ordering::Equal,
                RosterSort::Name => match a.l_name.cmp(&b.l_name) {
                    std::cmp::Ordering::Equal => a.f_name.cmp(&b.f_name),
                    o => o,
                },
                RosterSort::Position => a.position.cmp(&b.position),
                RosterSort::Separation => a.separation.cmp(&b.separation),
            });
        }
        roster_copy
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parsing_roster() {
        let er: EmployeeRoster = EmployeeRoster::for_tests();
        assert_eq!(6, er.len());
        let emp = er.find("John", "Johnson").unwrap();
        assert_eq!("John", emp.f_name);
        assert_eq!("Johnson", emp.l_name);
        assert_eq!("Manager", emp.position);
        assert_eq!("2016-12-31", emp.separation);
        let emp = er.find("Jake", "Jacobson").unwrap();
        assert_eq!("Jake", emp.f_name);
        assert_eq!("Jacobson", emp.l_name);
        assert_eq!("Programmer", emp.position);
        assert_eq!("", emp.separation);
    }

    #[test]
    fn parsing_bad_roster_line() {
        match EmployeeRoster::from_string("First Name | Last Name | Position") {
            Err(e) => assert_eq!(e.kind(), ErrorKind::InvalidInput),
            Ok(_) => panic!("bad roster line did not return error"),
        }
    }
}
