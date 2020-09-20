use chrono::{Datelike, Utc};

pub struct RetirementYears {
    pub years: i32,
    pub cur_year: i32,
    pub ret_year: i32,
}

impl RetirementYears {
    pub fn from_ages(cur_age: i32, ret_age: i32) -> RetirementYears {
        let years = ret_age - cur_age;
        let cur_year = RetirementYears::get_cur_year() as i32;
        let ret_year = cur_year + years;
        RetirementYears {years, cur_year, ret_year}
    }

    // TODO change this to calculate() which returns an enum
    pub fn show(&self) {
        if self.years < 0 {
            println!("It's {}, and you could have retired back in {}.", self.cur_year, self.ret_year);
        } else if self.years == 0 {
            println!("It's {}, and you can retire now.", self.cur_year);
        } else {
            println!("You have {} years left until you can retire.", self.years);
            println!("It's {}, so you can retire in {}.", self.cur_year, self.ret_year);
        }
    }

    // private
    fn get_cur_year() -> u32 {
        let now = Utc::now();
        let (_is_ce, year) = now.year_ce();
        year
    }
}

// TODO add tests
