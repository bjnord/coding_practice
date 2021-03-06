use chrono::{Datelike, DateTime, Local, naive, NaiveDate};
use lazy_static::lazy_static;
use regex::{Regex, RegexBuilder};
use std::fs;
use std::io::{self, ErrorKind};

#[derive(Debug, Clone)]
pub struct Employee {
    f_name: String,
    l_name: String,
    position: String,
    separation: NaiveDate,
}

impl Employee {
    #[cfg(test)]
    fn for_tests() -> Employee {
        Employee {
            f_name: String::from("Jonathan"),
            l_name: String::from("Doe"),
            position: String::from("Floor Sweeper"),
            separation: NaiveDate::from_ymd(2020, 3, 15),
        }
    }

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
        let separation = match NaiveDate::parse_from_str(tokens[3].trim(), "%Y-%m-%d") {
            Ok(d) => d,
            Err(_) => naive::MAX_DATE,
        };
        Some(Employee {f_name, l_name, position, separation})
    }

    pub fn name_matches(&self, pattern: &str) -> bool {
        let re = RegexBuilder::new(pattern)
            .case_insensitive(true)
            .build()
            .expect("invalid Regex");
        match re.is_match(&self.f_name) {
            true => true,
            false => re.is_match(&self.l_name),
        }
    }

    pub fn position_matches(&self, pattern: &str) -> bool {
        let re = RegexBuilder::new(pattern)
            .case_insensitive(true)
            .build()
            .expect("invalid Regex");
        re.is_match(&self.position)
    }

    pub fn separated_within(&self, months: u32) -> bool {
        Employee::months_since(&self.separation) <= months
    }

    // TODO extract months_since(a, b), rename this as today_months_since(a)
    //      then convert this comment to tests
    // future: 2020-09-22 since 2020-09-23 = 0*12 +  0 - 1 = -1 (= MAX)
    // today:  2020-09-22 since 2020-09-22 = 0*12 +  0 - 0 = 0
    // past:   2020-09-22 since 2020-08-23 = 0*12 +  1 - 1 = 0
    //         2020-09-22 since 2020-08-22 = 0*12 +  1 - 0 = 1
    //         2020-09-22 since 2019-12-22 = 1*12 + -3 - 0 = 9
    //         2020-09-22 since 2019-09-22 = 1*12 +  0 - 0 = 12
    //         2020-09-22 since 2019-08-22 = 1*12 +  1 - 0 = 13
    //
    // private
    fn months_since(a: &NaiveDate) -> u32 {
        let dt: DateTime<Local> = Local::now();
        let mut months: i32 = (dt.year() as i32 - a.year() as i32) * 12 + (dt.month() as i32 - a.month() as i32);
        if dt.day() < a.day() {
            months -= 1;
        }
        if months < 0 { u32::MAX } else { months as u32 }
    }

    pub fn separation_str(&self) -> String {
        match self.separation {
            naive::MAX_DATE => String::new(),
            d => String::from(d.format("%Y-%m-%d").to_string()),
        }
    }
}

#[derive(PartialEq)]
pub enum RosterSort {
    Unsorted,
    Name,
    Position,
    Separation,
}

#[derive(PartialEq)]
pub enum RosterFilter {
    Unfiltered,
    Name {pattern: String},
    Position {pattern: String},
    Separation {months: u32},
}

pub struct EmployeeRoster {
    roster: Vec<Employee>,
    filter: RosterFilter,
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
        Ok(EmployeeRoster {roster, filter: RosterFilter::Unfiltered, sort_order: RosterSort::Unsorted})
    }

    pub fn len(&self) -> usize {
        self.roster.len()
    }

    pub fn find(&self, f_name: &str, l_name: &str) -> Option<&Employee> {
        self.roster.iter().find(|e| e.f_name == f_name && e.l_name == l_name)
    }

    pub fn filter_by(&mut self, filter: RosterFilter) {
        self.filter = filter;
    }

    pub fn sort_by(&mut self, order: RosterSort) {
        self.sort_order = order;
    }

    pub fn print(&self) {
        println!("\
            First Name | Last Name  | Position          | Separation Date\n\
            -----------|------------|-------------------|----------------");
        for emp in self.filtered_sorted_roster() {
            println!("{:<10} | {:<10} | {:<17} | {:<15}", emp.f_name, emp.l_name, emp.position, emp.separation_str());
        }
    }

    // private
    fn filtered_sorted_roster(&self) -> Vec<Employee> {
        let mut roster_copy = self.roster.to_vec();
        roster_copy = roster_copy.into_iter()
            .filter(|e| match &self.filter {
                RosterFilter::Unfiltered => true,
                RosterFilter::Name {pattern} => e.name_matches(&pattern),
                RosterFilter::Position {pattern} => e.position_matches(&pattern),
                RosterFilter::Separation {months} => e.separated_within(*months),
            }).collect();
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
    fn first_name_matches() {
        let e: Employee = Employee::for_tests();
        assert_eq!(true, e.name_matches("Jo"));
        assert_eq!(true, e.name_matches("jo"));
        assert_eq!(true, e.name_matches("than"));
    }

    #[test]
    fn first_name_doesnt_match() {
        let e: Employee = Employee::for_tests();
        assert_eq!(false, e.name_matches("John"));
        assert_eq!(false, e.name_matches("john"));
    }

    #[test]
    fn last_name_matches() {
        let e: Employee = Employee::for_tests();
        assert_eq!(true, e.name_matches("Do"));
        assert_eq!(true, e.name_matches("Do"));
        assert_eq!(true, e.name_matches("oe"));
    }

    #[test]
    fn last_name_doesnt_match() {
        let e: Employee = Employee::for_tests();
        assert_eq!(false, e.name_matches("Roe"));
        assert_eq!(false, e.name_matches("roe"));
    }

    #[test]
    fn position_matches() {
        let e: Employee = Employee::for_tests();
        assert_eq!(true, e.position_matches("Flo"));
        assert_eq!(true, e.position_matches("flo"));
        assert_eq!(true, e.position_matches("per"));
    }

    #[test]
    fn position_doesnt_match() {
        let e: Employee = Employee::for_tests();
        assert_eq!(false, e.position_matches("Jan"));
        assert_eq!(false, e.position_matches("jan"));
    }

    #[test]
    fn gone_separated_within() {
        let e: Employee = Employee::for_tests();
        assert_eq!(false, e.separated_within(1));
        assert_eq!(true, e.separated_within(1200));
    }

    #[test]
    fn here_separated_within() {
        let e: Employee = Employee::from_tokens(vec!["Still", "Here", "Comptroller", ""]).unwrap();
        assert_eq!(false, e.separated_within(1));
        assert_eq!(false, e.separated_within(1200));
    }

    #[test]
    fn parsing_roster() {
        let er: EmployeeRoster = EmployeeRoster::for_tests();
        assert_eq!(6, er.len());
        let emp = er.find("John", "Johnson").unwrap();
        assert_eq!("John", emp.f_name);
        assert_eq!("Johnson", emp.l_name);
        assert_eq!("Manager", emp.position);
        assert_eq!("2016-12-31", emp.separation_str());
        let emp = er.find("Jake", "Jacobson").unwrap();
        assert_eq!("Jake", emp.f_name);
        assert_eq!("Jacobson", emp.l_name);
        assert_eq!("Programmer", emp.position);
        assert_eq!("", emp.separation_str());
    }

    #[test]
    fn parsing_bad_roster_line() {
        match EmployeeRoster::from_string("First Name | Last Name | Position") {
            Err(e) => assert_eq!(e.kind(), ErrorKind::InvalidInput),
            Ok(_) => panic!("bad roster line did not return error"),
        }
    }
}
