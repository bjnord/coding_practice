use itertools::Itertools;
use std::collections::HashSet;
use std::fmt;
use std::fs;
use std::io::{self, ErrorKind};
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone)]
struct PassportError(String);

impl fmt::Display for PassportError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Passport error: {}", self.0)
    }
}

impl std::error::Error for PassportError {}

#[derive(Debug, Clone)]
pub struct Field {
    name: String,
    value: String,
}

#[derive(Debug, Clone)]
pub struct Passport {
    fields: Vec<Field>,
}

impl FromStr for Passport {
    type Err = Box<dyn std::error::Error>;

    fn from_str(block: &str) -> Result<Self> {
        let line = block.replace("\n", " ");
        let mut fields: Vec<Field> = vec![];
        for field in line.split_whitespace() {
            if let Some((name, value)) = field.split(':').collect_tuple() {
                fields.push(Field{name: String::from(name), value: String::from(value)});
            } else {
                let e = format!("invalid input field format [{}]", field);
                // FIXME use PassportError and into()
                return Err(Box::new(io::Error::new(ErrorKind::InvalidInput, e)));
            };
        }
        Ok(Self{fields})
    }
}

impl Passport {
    /// Read passports from file.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if
    /// a passport is found with an invalid format.
    pub fn read_from_file(path: &str) -> Result<Vec<Passport>> {
        let s: String = fs::read_to_string(path)?;
        s.split("\n\n").map(str::parse).collect()
    }

    /// Are passport fields complete?
    #[must_use]
    pub fn is_complete(&self) -> bool {
        // per puzzle, ignore cid
        let required = vec!["byr", "iyr", "eyr", "hgt", "ecl", "pid", "hcl"];
        let mut required: HashSet<&str> = required.into_iter().collect();
        for field in &self.fields {
            if required.contains(&field.name[..]) {
                required.remove(&field.name[..]);
            }
        }
        required.is_empty()
    }

    /// Are passport fields valid and complete?
    #[must_use]
    pub fn is_valid(&self) -> bool {
        // per puzzle, ignore cid
        let required = vec!["byr", "iyr", "eyr", "hgt", "ecl", "pid", "hcl"];
        let mut required: HashSet<&str> = required.into_iter().collect();
        for field in &self.fields {
            let valid_field = match &field.name[..] {
                "byr" => Passport::year_in_range(&field.value, 1920, 2002),
                "iyr" => Passport::year_in_range(&field.value, 2010, 2020),
                "eyr" => Passport::year_in_range(&field.value, 2020, 2030),
                "hgt" => Passport::valid_height(&field.value),
                "hcl" => Passport::valid_hair_color(&field.value),
                "ecl" => Passport::valid_eye_color(&field.value),
                "pid" => Passport::valid_passport_id(&field.value),
                "cid" => true,
                _ => false,
            };
            if !valid_field {
                continue;
            }
            if required.contains(&field.name[..]) {
                required.remove(&field.name[..]);
            }
        }
        required.is_empty()
    }

    // Is field value a year within the given range?
    // #[must_use]
    fn year_in_range(year: &str, min_year: u32, max_year: u32) -> bool {
        if let Ok(year) = year.parse::<u32>() {
            year >= min_year && year <= max_year
        } else {
            false
        }
    }

    // Is field value a valid height in inches or cm?
    // #[must_use]
    fn valid_height(height: &str) -> bool {
        let l = height.len();
        if l < 2 {
            return false;
        }
        let value = &height[..l-2];
        if let Ok(value) = value.parse::<u32>() {
            match &height[l-2..l] {
                "cm" => value >= 150 && value <= 193,
                "in" => value >= 59 && value <= 76,
                _ => false,
            }
        } else {
            false
        }
    }

    // Is field value a valid hair color (RGB color value)?
    // #[must_use]
    fn valid_hair_color(color: &str) -> bool {
        let mut i = color.chars();
        if let Some(c) = i.next() {
            if c != '#' {
                return false;
            }
        } else {
            return false;
        }
        i.map(|c| if c.is_ascii_hexdigit() { 1 } else { -10000 }).sum::<i32>() == 6
    }

    // Is field value a valid eye color?
    // #[must_use]
    fn valid_eye_color(color: &str) -> bool {
        vec!["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].contains(&color)
    }

    // Is field value a valid passport ID?
    // #[must_use]
    fn valid_passport_id(pid: &str) -> bool {
        pid.chars().map(|c| if c.is_ascii_digit() { 1 } else { -10000 }).sum::<i32>() == 9
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let passports = Passport::read_from_file("input/example1.txt").unwrap();
        assert_eq!(2, passports.into_iter().filter(|p| p.is_valid() ).count());
    }

    #[test]
    fn test_read_from_file2() {
        let passports = Passport::read_from_file("input/example2.txt").unwrap();
        assert_eq!(4, passports.into_iter().filter(|p| p.is_valid() ).count());
    }

    #[test]
    fn test_read_from_file_no_file() {
        let passports = Passport::read_from_file("input/example99.txt");
        assert!(passports.is_err());
    }

    #[test]
    fn test_read_from_file_bad_format() {
        let passports = Passport::read_from_file("input/bad1.txt");
        assert!(passports.is_err());
    }

    #[test]
    fn test_year_in_range_too_small() {
        assert_eq!(false, Passport::year_in_range("2001", 2002, 2012));
    }

    #[test]
    fn test_year_in_range_just_big_enough() {
        assert_eq!(true, Passport::year_in_range("2002", 2002, 2012));
    }

    #[test]
    fn test_year_in_range_just_small_enough() {
        assert_eq!(true, Passport::year_in_range("2012", 2002, 2012));
    }

    #[test]
    fn test_year_in_range_too_big() {
        assert_eq!(false, Passport::year_in_range("2013", 2002, 2012));
    }

    #[test]
    fn test_year_in_range_blank() {
        assert_eq!(false, Passport::year_in_range("", 2002, 2012));
    }

    #[test]
    fn test_year_in_range_non_digits() {
        assert_eq!(false, Passport::year_in_range("X014", 2002, 2012));
    }

    #[test]
    fn test_valid_height_cm_too_small() {
        assert_eq!(false, Passport::valid_height("149cm"));
    }

    #[test]
    fn test_valid_height_cm_just_big_enough() {
        assert_eq!(true, Passport::valid_height("150cm"));
    }

    #[test]
    fn test_valid_height_cm_just_small_enough() {
        assert_eq!(true, Passport::valid_height("193cm"));
    }

    #[test]
    fn test_valid_height_cm_too_big() {
        assert_eq!(false, Passport::valid_height("194cm"));
    }

    #[test]
    fn test_valid_height_in_too_small() {
        assert_eq!(false, Passport::valid_height("58in"));
    }

    #[test]
    fn test_valid_height_in_just_big_enough() {
        assert_eq!(true, Passport::valid_height("59in"));
    }

    #[test]
    fn test_valid_height_in_just_small_enough() {
        assert_eq!(true, Passport::valid_height("76in"));
    }

    #[test]
    fn test_valid_height_in_too_big() {
        assert_eq!(false, Passport::valid_height("77in"));
    }

    #[test]
    fn test_valid_height_blank() {
        assert_eq!(false, Passport::valid_height(""));
    }

    #[test]
    fn test_valid_height_no_unit() {
        assert_eq!(false, Passport::valid_height("1"));
    }

    #[test]
    fn test_valid_height_bad_unit() {
        assert_eq!(false, Passport::valid_height("1930mm"));
    }

    #[test]
    fn test_valid_height_no_value() {
        assert_eq!(false, Passport::valid_height("cm"));
    }

    #[test]
    fn test_valid_hair_color() {
        assert_eq!(true, Passport::valid_hair_color(&String::from("#779ca7")));
    }

    #[test]
    fn test_valid_hair_color_upper() {
        assert_eq!(true, Passport::valid_hair_color(&String::from("#CC0066")));
    }

    #[test]
    fn test_valid_hair_color_blank() {
        assert_eq!(false, Passport::valid_hair_color(&String::new()));
    }

    #[test]
    fn test_valid_hair_color_no_sharp() {
        assert_eq!(false, Passport::valid_hair_color(&String::from("02468a")));
    }

    #[test]
    fn test_valid_hair_color_non_hex() {
        assert_eq!(false, Passport::valid_hair_color(&String::from("#135x9b")));
    }

    #[test]
    fn test_valid_hair_color_too_few() {
        assert_eq!(false, Passport::valid_hair_color(&String::from("#222")));
    }

    #[test]
    fn test_valid_hair_color_too_many() {
        assert_eq!(false, Passport::valid_hair_color(&String::from("#ca86420")));
    }

    #[test]
    fn test_valid_hair_color_trickery() {
        assert_eq!(false, Passport::valid_hair_color(&String::from("#ca86x420")));
    }

    #[test]
    fn test_valid_eye_color_blue() {
        assert_eq!(true, Passport::valid_eye_color("blu"));
    }

    #[test]
    fn test_valid_eye_color_hazel() {
        assert_eq!(true, Passport::valid_eye_color("hzl"));
    }

    #[test]
    fn test_valid_eye_color_cyan() {
        assert_eq!(false, Passport::valid_eye_color("cyn"));
    }

    #[test]
    fn test_valid_passport_id() {
        assert_eq!(true, Passport::valid_passport_id(&String::from("078051120")));
    }

    #[test]
    fn test_valid_passport_id_blank() {
        assert_eq!(false, Passport::valid_passport_id(&String::new()));
    }

    #[test]
    fn test_valid_passport_id_non_digit() {
        assert_eq!(false, Passport::valid_passport_id(&String::from("078-51120")));
    }

    #[test]
    fn test_valid_passport_id_too_short() {
        assert_eq!(false, Passport::valid_passport_id(&String::from("0123456789")));
    }

    #[test]
    fn test_valid_passport_id_too_long() {
        assert_eq!(false, Passport::valid_passport_id(&String::from("01234567")));
    }
}
