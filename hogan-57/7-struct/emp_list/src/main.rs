use std::io::{self, Write};

struct EmployeeList {
    employees: Vec<String>,
}

impl EmployeeList {
    fn from_memory() -> EmployeeList {
        let mut employees = Vec::new();
        employees.push(String::from("Fred Flintstone"));
        employees.push(String::from("Wilma Flintstone"));
        employees.push(String::from("Barney Rubble"));
        employees.push(String::from("Betty Rubble"));
        EmployeeList {employees}
    }

    // TODO from_file(filename)

    fn count(&self) -> usize {
        self.employees.len()
    }

    fn dump(&self) {
        let count = self.count();
        match count {
            1 => { println!("There is 1 employee:"); },
            _ => { println!("There are {} employees:", count); },
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
    let mut emp_list = EmployeeList::from_memory();
    emp_list.dump();
    loop {
        println!("");
        let name = read_input("Enter an employee name to remove: ");
        emp_list.remove(&name[..]);
        println!("");
        match emp_list.count() {
            0 => { break; },
            _ => { emp_list.dump(); },
        }
    }
    println!("All employees removed.");
}

fn read_input(prompt: &str) -> String {
    print_prompt(prompt);
    read_response()
}

fn print_prompt(prompt: &str) {
    print!("{}", prompt);
    io::stdout().flush()
        .expect("Failed to flush");
}

fn read_response() -> String {
    let mut input = String::new();
    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line");
    String::from(input.trim())
}
