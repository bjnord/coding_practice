use lazy_static::lazy_static;
use regex::Regex;

pub struct Employee {
    f_name: String,
    l_name: String,
    position: String,
    separation: String,  // TODO date type
}

impl Employee {
    #[cfg(test)]
    fn for_tests() -> Vec<Employee> {
        Employee::from_string("\
            Name                | Position          | Separation Date\n\
            --------------------|-------------------|----------------\n\
            John Johnson        | Manager           | 2016-12-31\n\
            Tou Xiong           | Software Engineer | 2016-10-05\n\
            Michaela Michaelson | District Manager  | 2015-12-19     \n\
            Jake Jacobson       | Programmer        |                \n\
            Jacquelyn Jackson   | DBA               | \n\
            Sally Weber         | Web Developer     | 2015-12-18\n")
    }

    pub fn from_file(filename: &str) -> Vec<Employee> {
        // TODO read file to string, pass to from_string()
        //      change return types of both to Result for errors
        Vec::<Employee>::new()
    }

    pub fn from_string(input: &str) -> Vec<Employee> {
        let mut roster: Vec<Employee> = Vec::<Employee>::new();
        let lines: Vec<&str> = input.split("\n").collect();
        for line in lines {
            let tokens: Vec<&str> = line.split("|").collect();
            if tokens.len() == 1 && tokens[0].trim().is_empty() {
                continue;  // ignore blank lines
            } else if tokens.len() != 3 {
                panic!("line in unknown format (tokens={}): [{}]", tokens.len(), line);
            }
            match Employee::from_tokens(tokens) {
                Some(emp) => roster.push(emp),
                None => (),
            }
        }
        roster
    }

    pub fn from_tokens(tokens: Vec<&str>) -> Option<Employee> {
        lazy_static! {
            static ref LINE_RE: Regex = Regex::new(r"^---*$").unwrap();
        }
        let name = String::from(tokens[0].trim());
        if name == "Name" || LINE_RE.is_match(&name) {
            return None;
        }
        let names: Vec<&str> = name.split_whitespace().collect();
        let f_name = String::from(names[0]);
        let l_name = String::from(names[1]);
        let position = String::from(tokens[1].trim());
        let separation = String::from(tokens[2].trim());
        Some(Employee {f_name, l_name, position, separation})
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parsing_roster() {
        let roster: Vec<Employee> = Employee::for_tests();
        assert_eq!(6, roster.len());
        let emp = &roster[0];
        assert_eq!("John", emp.f_name);
        assert_eq!("Johnson", emp.l_name);
        assert_eq!("Manager", emp.position);
        assert_eq!("2016-12-31", emp.separation);
        let emp = &roster[3];
        assert_eq!("Jake", emp.f_name);
        assert_eq!("Jacobson", emp.l_name);
        assert_eq!("Programmer", emp.position);
        assert_eq!("", emp.separation);
    }
}
