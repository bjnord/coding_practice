use chrono::{Datelike, Utc};

// TODO try struct-like enum variants here (make RetirementYears fields private again)
#[derive(Debug,PartialEq)]
pub enum RetireWhen {
    Future,
    Now,
    Past,
}

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

    pub fn retire_when(&self) -> RetireWhen {
        if self.years < 0 {
            RetireWhen::Past
        } else if self.years == 0 {
            RetireWhen::Now
        } else {
            RetireWhen::Future
        }
    }

    // private
    fn get_cur_year() -> u32 {
        let now = Utc::now();
        let (_is_ce, year) = now.year_ce();
        year
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn future_retirement_calc() {
        let cur_year = RetirementYears::get_cur_year() as i32;
        let ry = RetirementYears::from_ages(49, 65);
        assert_eq!(16, ry.years);
        assert_eq!(cur_year + 16, ry.ret_year);
    }

    #[test]
    fn future_retirement_when() {
        let ry = RetirementYears::from_ages(49, 65);
        assert_eq!(RetireWhen::Future, ry.retire_when());
    }

    #[test]
    fn now_retirement_calc() {
        let cur_year = RetirementYears::get_cur_year() as i32;
        let ry = RetirementYears::from_ages(72, 72);
        assert_eq!(0, ry.years);
        assert_eq!(cur_year, ry.ret_year);
    }

    #[test]
    fn now_retirement_when() {
        let ry = RetirementYears::from_ages(72, 72);
        assert_eq!(RetireWhen::Now, ry.retire_when());
    }

    #[test]
    fn past_retirement_calc() {
        let cur_year = RetirementYears::get_cur_year() as i32;
        let ry = RetirementYears::from_ages(65, 55);
        assert_eq!(-10, ry.years);
        assert_eq!(cur_year - 10, ry.ret_year);
    }

    #[test]
    fn past_retirement_when() {
        let ry = RetirementYears::from_ages(65, 55);
        assert_eq!(RetireWhen::Past, ry.retire_when());
    }
}
