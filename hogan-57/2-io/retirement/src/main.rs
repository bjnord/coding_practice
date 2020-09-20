extern crate interact_io;
use interact_io::readln;
use retirement::RetirementYears;

fn main() {
    let cur_age = readln::read_i32_range("What is your current age? ", 1, 120).unwrap();
    let ret_age = readln::read_i32_range("At what age would you like to retire? ", 1, 120).unwrap();
    RetirementYears::from_ages(cur_age, ret_age).show();
}
