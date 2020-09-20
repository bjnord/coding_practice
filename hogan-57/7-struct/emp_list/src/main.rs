extern crate interact_io;
use emp_list::EmployeeList;
use interact_io::readln;

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
