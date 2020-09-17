use std::io::{self, Write};

// TODO create EmployeeList type

fn main() {
    let mut emp_list = load_employees();
    dump_employees(&emp_list);
    println!("");
    let name = read_input("Enter an employee name to remove: ");
    delete_employee(&mut emp_list, &name[..]);
    println!("");
    dump_employees(&emp_list);
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

// TODO get these from a file
fn load_employees() -> Vec<String> {
    let mut emp_list = Vec::new();
    emp_list.push(String::from("Fred Flintstone"));
    emp_list.push(String::from("Wilma Flintstone"));
    emp_list.push(String::from("Barney Rubble"));
    emp_list.push(String::from("Betty Rubble"));
    emp_list
}

fn dump_employees(emp_list: &Vec<String>) {
    // FIXME singular vs plural
    println!("There are {} employees:", emp_list.len());
    for emp in emp_list {
        println!("{}", emp);
    }
}

fn delete_employee(emp_list: &mut Vec<String>, name: &str) {
    match emp_list.iter().position(|x| *x == name) {
        Some(i) => { emp_list.remove(i); },
        None => { println!("Employee '{}' not found.", name); },
    }
}
