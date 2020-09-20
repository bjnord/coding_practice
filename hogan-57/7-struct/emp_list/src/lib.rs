use std::fs::File;
use std::io::{BufRead, BufReader};

pub struct EmployeeList {
    employees: Vec<String>,
}

impl EmployeeList {
    #[allow(dead_code)]
    fn from_memory() -> EmployeeList {
        let mut employees = Vec::new();
        employees.push(String::from("Fred Flintstone"));
        employees.push(String::from("Wilma Flintstone"));
        employees.push(String::from("Barney Rubble"));
        employees.push(String::from("Betty Rubble"));
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

    pub fn count(&self) -> usize {
        self.employees.len()
    }

    pub fn dump(&self) {
        let count = self.count();
        match count {
            1 => println!("There is 1 employee:"),
            _ => println!("There are {} employees:", count),
        }
        for emp in &self.employees {
            println!("{}", emp);
        }
    }

    pub fn remove(&mut self, name: &str) {
        match self.employees.iter().position(|n| *n == name) {
            Some(i) => { self.employees.remove(i); },
            None => { println!("Employee '{}' not found.", name); },
        }
    }
}

// TODO write tests
