use regex::Regex;
// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};

#[derive(Debug)]
struct Employee {
    f_name: String,
    l_name: String,
    emp_id: String,
    zip: String,
}

fn main() {
    let emp = read_employee();
    validate_employee(&emp);
    //println!("employee data: {:#?}", emp);
}

fn read_employee() -> Employee {
    let f_name = read_input("Enter the first name: ");
    let l_name = read_input("Enter the last name: ");
    let zip = read_input("Enter the ZIP code: ");
    let mut emp_id = read_input("Enter an employee ID: ");
    emp_id.make_ascii_uppercase();
    Employee {f_name, l_name, zip, emp_id}
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

fn validate_employee(emp: &Employee) {
    let e_f_name = validate_f_name(&emp);
    let e_l_name = validate_l_name(&emp);
    let e_emp_id = validate_emp_id(&emp);
    let e_zip = validate_zip(&emp);
    if e_f_name && e_l_name && e_emp_id && e_zip {
        println!("There were no errors found.");
    }
}

fn validate_f_name(emp: &Employee) -> bool {
    if emp.f_name.len() == 0 {
        println!("The first name must be filled in.");
        false
    } else if emp.f_name.len() < 2 {
        println!("\"{}\" is not a valid first name. It is too short.", emp.f_name);
        false
    } else {
        true
    }
}

fn validate_l_name(emp: &Employee) -> bool {
    if emp.l_name.len() == 0 {
        println!("The last name must be filled in.");
        false
    } else if emp.l_name.len() < 2 {
        println!("\"{}\" is not a valid last name. It is too short.", emp.l_name);
        false
    } else {
        true
    }
}

fn validate_emp_id(emp: &Employee) -> bool {
    let re = Regex::new(r"^(?i)[a-z]{2}-\d{4}$").unwrap();
    if re.is_match(&emp.emp_id[..]) {
        true
    } else {
        println!("{} is not a valid ID.", emp.emp_id);
        false
    }
}

fn validate_zip(emp: &Employee) -> bool {
    let re = Regex::new(r"^\d{5}(?:-\d{4})?$").unwrap();
    if re.is_match(&emp.zip[..]) {
        true
    } else {
        println!("The ZIP code must be numeric.");
        false
    }
}
