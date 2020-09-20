extern crate interact_io;
use interact_io::readln;
use retirement::RetirementYears;

fn main() {
    let cur_age = readln::read_i32_range("What is your current age? ", 1, 120).unwrap();
    let ret_age = readln::read_i32_range("At what age would you like to retire? ", 1, 120).unwrap();
    let ry = RetirementYears::from_ages(cur_age, ret_age);
    show_retirement(ry);
}

fn show_retirement(ry: RetirementYears) {
    if ry.years < 0 {
        println!("It's {}, and you could have retired back in {}.", ry.cur_year, ry.ret_year);
    } else if ry.years == 0 {
        println!("It's {}, and you can retire now.", ry.cur_year);
    } else {
        println!("You have {} years left until you can retire.", ry.years);
        println!("It's {}, so you can retire in {}.", ry.cur_year, ry.ret_year);
    }
}
