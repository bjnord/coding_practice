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

impl Employee {
    fn validate(&self) {
        // FIXME make this 4-way test more concise
        let e_f_name = self.validate_f_name();
        let e_l_name = self.validate_l_name();
        let e_emp_id = self.validate_emp_id();
        let e_zip = self.validate_zip();
        if e_f_name && e_l_name && e_emp_id && e_zip {
            println!("There were no errors found.");
        }
    }

    fn validate_f_name(&self) -> bool {
        if self.f_name.len() == 0 {
            println!("The first name must be filled in.");
            false
        } else if self.f_name.len() < 2 {
            println!("\"{}\" is not a valid first name. It is too short.", self.f_name);
            false
        } else {
            true
        }
    }

    fn validate_l_name(&self) -> bool {
        if self.l_name.len() == 0 {
            println!("The last name must be filled in.");
            false
        } else if self.l_name.len() < 2 {
            println!("\"{}\" is not a valid last name. It is too short.", self.l_name);
            false
        } else {
            true
        }
    }

    fn validate_emp_id(&self) -> bool {
        // FIXME use lazy_static; see:
        //       https://docs.rs/regex/1.3.9/regex/#example-avoid-compiling-the-same-regex-in-a-loop
        let re = Regex::new(r"^(?i)[a-z]{2}-\d{4}$").unwrap();
        if re.is_match(&self.emp_id[..]) {
            true
        } else {
            println!("{} is not a valid ID.", self.emp_id);
            false
        }
    }

    fn validate_zip(&self) -> bool {
        // FIXME use lazy_static; see:
        //       https://docs.rs/regex/1.3.9/regex/#example-avoid-compiling-the-same-regex-in-a-loop
        let re = Regex::new(r"^\d{5}(?:-\d{4})?$").unwrap();
        if re.is_match(&self.zip[..]) {
            true
        } else {
            println!("The ZIP code must be numeric.");
            false
        }
    }
}

fn main() {
    let emp = read_employee();
    emp.validate();
    //println!("employee data: {:#?}", emp);
}

// TODO move this to impl also
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
