extern crate interact_io;
use interact_io::readln;
use std::fs::File;
use std::io::{BufRead, BufReader};

// TODO move EmployeeList to its own file; write tests

struct EmployeeList {
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

    fn from_file(filename: &str) -> EmployeeList {
        let mut employees = Vec::new();
        let reader = BufReader::new(File::open(filename).expect("Cannot open employee file"));
        for line in reader.lines() {
            employees.push(String::from(line.unwrap()));
        }
        EmployeeList {employees}
    }

    fn count(&self) -> usize {
        self.employees.len()
    }

    fn dump(&self) {
        let count = self.count();
        match count {
            1 => println!("There is 1 employee:"),
            _ => println!("There are {} employees:", count),
        }
        for emp in &self.employees {
            println!("{}", emp);
        }
    }

    fn remove(&mut self, name: &str) {
        match self.employees.iter().position(|n| *n == name) {
            Some(i) => { self.employees.remove(i); },
            None => { println!("Employee '{}' not found.", name); },
        }
    }
}

fn main() {
    let mut emp_list = EmployeeList::from_file("employees.txt");
    emp_list.dump();
    loop {
        println!("");
        let name = readln::read_string("Enter an employee name to remove: ").unwrap();
        emp_list.remove(&name);
        println!("");
        match emp_list.count() {
            0 => break,
            _ => emp_list.dump(),
        }
    }
    println!("All employees removed.");
}
