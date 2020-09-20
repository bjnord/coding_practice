extern crate interact_io;
use interact_io::readln;
use pass_strength::{password_count, password_grade};

fn main() {
    let passwd = readln::read_string("Enter a password to test: ").unwrap();
    let pcount = password_count(&passwd);
    let grade = password_grade(pcount);
    println!("The password '{}' is a {} password.", passwd, grade);
}
