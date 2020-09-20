extern crate interact_io;
use interact_io::readln;
use retirement::{RetirementYears, RetireWhen};

fn main() {
    let cur_age = readln::read_i32_range("What is your current age? ", 1, 120).unwrap();
    let ret_age = readln::read_i32_range("At what age would you like to retire? ", 1, 120).unwrap();
    let ry = RetirementYears::from_ages(cur_age, ret_age);
    show_retirement(ry);
}

fn show_retirement(ry: RetirementYears) {
    match ry.retire_when() {
        RetireWhen::Past {cur_year, ret_year} => println!("It's {}, and you could have retired back in {}.", cur_year, ret_year),
        RetireWhen::Now {cur_year} => println!("It's {}, and you can retire now.", cur_year),
        RetireWhen::Future {years, cur_year, ret_year} => {
            println!("You have {} years left until you can retire.", years);
            println!("It's {}, so you can retire in {}.", cur_year, ret_year);
        }
    }
}
