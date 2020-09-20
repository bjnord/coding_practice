extern crate interact_io;
use interact_io::readln;
use valid_input::Employee;

fn main() {
    let emp = read_employee();
    emp.validate();
}

fn read_employee() -> Employee {
    let f_name = readln::read_string("Enter the first name: ").unwrap();
    let l_name = readln::read_string("Enter the last name: ").unwrap();
    let zip = readln::read_string("Enter the ZIP code: ").unwrap();
    let mut emp_id = readln::read_string("Enter an employee ID: ").unwrap();
    emp_id.make_ascii_uppercase();
    Employee {f_name, l_name, zip, emp_id}
}
