use chrono::{Datelike, Utc};
extern crate interact_io;
use interact_io::readln;

fn main() {
    let cur_age = readln::read_i32_range("What is your current age? ", 1, 120);
    let ret_age = readln::read_i32_range("At what age would you like to retire? ", 1, 120);
    let years = ret_age - cur_age;
    let cur_year = get_cur_year() as i32;
    // FIXME move this to its own function:
    if years < 0 {
        let ret_year = cur_year + years;
        println!("It's {}, and you could have retired back in {}.", cur_year, ret_year);
    } else if years == 0 {
        println!("It's {}, and you can retire now.", cur_year);
    } else {
        println!("You have {} years left until you can retire.", years);
        let ret_year = cur_year + years;
        println!("It's {}, so you can retire in {}.", cur_year, ret_year);
    }
}

fn get_cur_year() -> u32 {
    let now = Utc::now();
    let (_is_ce, year) = now.year_ce();
    year
}
