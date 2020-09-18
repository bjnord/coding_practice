use chrono::{Datelike, Utc};
extern crate interact_io;
use interact_io::readln;

struct RetirementYears {
    years: i32,
    cur_year: i32,
}

impl RetirementYears {
    fn from_ages(cur_age: i32, ret_age: i32) -> RetirementYears {
        let years = ret_age - cur_age;
        let cur_year = get_cur_year() as i32;
        RetirementYears {years, cur_year}
    }

    fn show(&self) {
        if self.years < 0 {
            let ret_year = self.cur_year + self.years;
            println!("It's {}, and you could have retired back in {}.", self.cur_year, ret_year);
        } else if self.years == 0 {
            println!("It's {}, and you can retire now.", self.cur_year);
        } else {
            println!("You have {} years left until you can retire.", self.years);
            let ret_year = self.cur_year + self.years;
            println!("It's {}, so you can retire in {}.", self.cur_year, ret_year);
        }
    }
}

fn main() {
    let cur_age = readln::read_i32_range("What is your current age? ", 1, 120);
    let ret_age = readln::read_i32_range("At what age would you like to retire? ", 1, 120);
    RetirementYears::from_ages(cur_age, ret_age).show();
}

fn get_cur_year() -> u32 {
    let now = Utc::now();
    let (_is_ce, year) = now.year_ce();
    year
}
