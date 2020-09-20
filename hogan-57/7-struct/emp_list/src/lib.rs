use std::fs::File;
use std::io::{BufRead, BufReader};

pub struct EmployeeList {
    employees: Vec<String>,
}

impl EmployeeList {
    #[cfg(test)]
    pub fn from_array(a: &[&str]) -> EmployeeList {
        let mut employees = Vec::new();
        for v in a.iter() {
            employees.push(String::from(*v));
        }
        EmployeeList {employees}
    }

    pub fn from_file(filename: &str) -> EmployeeList {
        let mut employees = Vec::new();
        let reader = BufReader::new(File::open(filename).expect("Cannot open employee file"));
        for line in reader.lines() {
            employees.push(String::from(line.unwrap()));
        }
        EmployeeList {employees}
    }

    pub fn len(&self) -> usize {
        self.employees.len()
    }

    pub fn contains(&self, name: &str) -> bool {
        match self.employees.iter().find(|n| *n == name) {
            Some(_) => true,
            None => false,
        }
    }

    // TODO move output (here and remove()) to src/main.rs
    //      needs method to return custom read-only Employee iterator
    //      that does NOT allow the strings to be altered
    pub fn dump(&self) {
        match self.len() {
            1 => println!("There is 1 employee:"),
            n => println!("There are {} employees:", n),
        }
        for emp in &self.employees {
            println!("{}", emp);
        }
    }

    pub fn remove(&mut self, name: &str) -> Option<String> {
        match self.employees.iter().position(|n| *n == name) {
            Some(i) => {
                Some(self.employees.remove(i))
            },
            None => {
                println!("Employee '{}' not found.", name);
                None
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_creation_and_len() {
        let el = EmployeeList::from_array(&["Fred Flintstone", "Wilma Flintstone", "Barney Rubble", "Betty Rubble"]);
        assert_eq!(4, el.len());
        assert_eq!(true, el.contains("Betty Rubble"));
        assert_eq!(false, el.contains("Bam Bam Rubble"));
    }

    #[test]
    fn test_removal_when_contains() {
        let mut el = EmployeeList::from_array(&["Fred Flintstone", "Wilma Flintstone", "Barney Rubble", "Betty Rubble"]);
        el.remove("Barney Rubble").expect("failed to remove Barney Rubble");
        assert_eq!(false, el.contains("Barney Rubble"));
    }

    #[test]
    fn test_removal_when_doesnt_contain() {
        let mut el = EmployeeList::from_array(&["Fred Flintstone", "Wilma Flintstone", "Barney Rubble", "Betty Rubble"]);
        match el.remove("Pebbles Flintstone") {
            Some(_) => panic!("removed nonexistent Pebbles Flintstone"),
            None => (),
        }
    }
}
