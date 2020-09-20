use lazy_static::lazy_static;
use regex::Regex;

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

pub struct EmployeeRoster {
    roster: Vec<Employee>,
}

impl EmployeeRoster {
    #[cfg(test)]
    fn for_tests() -> EmployeeRoster {
        EmployeeRoster::from_string("\
            First Name | Last Name  | Position          | Separation Date\n\
            -----------|------------|-------------------|----------------\n\
            John       | Johnson    | Manager           | 2016-12-31\n\
            Tou        | Xiong      | Software Engineer | 2016-10-05\n\
            Michaela   | Michaelson | District Manager  | 2015-12-19     \n\
            Jake       | Jacobson   | Programmer        |                \n\
            Jacquelyn  | Jackson    | DBA               | \n\
            Sally      | Weber      | Web Developer     | 2015-12-18\n")
    }

    pub fn from_file(_filename: &str) -> EmployeeRoster {
        // TODO read file to string, pass to from_string()
        //      change return types of both to Result for errors
        EmployeeRoster::from_string("")
    }

    pub fn from_string(input: &str) -> EmployeeRoster {
        let mut roster: Vec<Employee> = Vec::<Employee>::new();
        let lines: Vec<&str> = input.split("\n").collect();
        for line in lines {
            let tokens: Vec<&str> = line.split("|").collect();
            if tokens.len() == 1 && tokens[0].trim().is_empty() {
                // FIXME add blank lines to test input, to exercise this check
                continue;  // ignore blank lines
            } else if tokens.len() != 4 {
                // FIXME return error Result
                panic!("line in unknown format (tokens={}): [{}]", tokens.len(), line);
            }
            match Employee::from_tokens(tokens) {
                Some(emp) => roster.push(emp),
                None => (),
            }
        }
        EmployeeRoster {roster}
    }

    pub fn len(&self) -> usize {
        self.roster.len()
    }

    pub fn find(&self, f_name: &str, l_name: &str) -> Option<&Employee> {
        self.roster.iter().find(|e| e.f_name == f_name && e.l_name == l_name)
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
}
