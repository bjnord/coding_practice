/// Problem 19: [Counting Sundays](https://projecteuler.net/problem=19)

use std::fmt;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Sunday {
    leap: usize,  // 0=not leap year, 1=leap year
    year: usize,  // e.g. 1901
    mon: usize,   // 1-12
    mday: usize,  // 1-31
}

impl fmt::Display for Sunday {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut l = self.leap;
        if self.mon < 2 || (self.mon == 2 && self.mday < 29) {
            l = 0;
        }
        let lc = match l {
            0 => "",
            _ => "*",
        };
        write!(f, "{}-{:02}-{:02}{}", self.year, self.mon, self.mday, lc)
    }
}

const DAYS: [[usize; 13]; 2] = [
    [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    [1, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
];

pub struct SundayIter {
    s: Sunday,
    max_year: usize,
}

impl Iterator for SundayIter {
    type Item = Sunday;

    fn next(&mut self) -> Option<Self::Item> {
        self.s.mday += 7;
        if self.s.mday > DAYS[self.s.leap][self.s.mon] {
            self.s.mday -= DAYS[self.s.leap][self.s.mon];
            self.s.mon += 1;
            if self.s.mon > 12 {
                self.s.mon = 1;
                self.s.year += 1;
                if self.s.year > self.max_year {
                    return None;
                }
                if self.s.year.rem_euclid(4) == 0 && self.s.year.rem_euclid(100) != 0 {
                    self.s.leap = 1;
                } else {
                    self.s.leap = 0;
                }
            }
        }
        Some(self.s)
    }
}

pub struct Problem0019 { }

impl Problem0019 {
    /// How many Sundays fall on the 1st of the month in the year range
    /// given? (`min_year` and `max_year` are inclusive and 4 digits)
    #[must_use]
    pub fn solve(min_year: usize, max_year: usize) -> usize {
        let i = Problem0019::iter(max_year);
        i.filter(|s| s.year >= min_year && s.mday == 1).count()
    }

    pub fn iter(max_year: usize) -> SundayIter {
        let sunday = Sunday {
            leap: 0,
            year: 1899,
            mon: 12,
            mday: 31,
        };
        SundayIter { s: sunday, max_year }
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 19 answer is {}", Self::solve(1901, 2000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0019::solve(1900, 1901);
        assert_eq!(4, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0019::solve(1901, 2000);
        assert_eq!(171, answer);
    }

    #[test]
    fn test_sunday_iter() {
        let i = Problem0019::iter(1900);
        let exp = vec!["1900-01-07", "1900-01-14", "1900-01-21", "1900-01-28",
            "1900-02-04", "1900-02-11", "1900-02-18", "1900-02-25",
            "1900-03-04", "1900-03-11"];
        let act: Vec<String> = i.take(10).map(|s| s.to_string()).collect();
        assert_eq!(exp, act);
    }

    #[test]
    fn test_sunday_iter_leap() {
        let i = Problem0019::iter(1904);
        let exp = vec!["1904-01-03", "1904-01-10", "1904-01-17", "1904-01-24", "1904-01-31",
            "1904-02-07", "1904-02-14", "1904-02-21", "1904-02-28",
            "1904-03-06*", "1904-03-13*"];
        let act: Vec<String> = i.skip(4 * 52).take(11).map(|s| s.to_string()).collect();
        assert_eq!(exp, act);
    }
}
