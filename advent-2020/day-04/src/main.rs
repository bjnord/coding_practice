#![warn(clippy::pedantic)]

use std::collections::HashSet;
use std::error;
use std::fs;
use std::io::{self, ErrorKind};
use std::time::Instant;

struct Passport {
    valid: bool,
}

fn main() {
    let start = Instant::now();
    part1();
    part2();
    let duration = start.elapsed();
    eprintln!("Finished after {:?}", duration);
}

/// Output solution for part 1.
fn part1() {
    let passports = read_passports("input/input.txt").unwrap();
    let count = passports.into_iter().filter(|p| p.valid ).count();
    println!("== PART 1 ==");
    println!("{} passports are valid (should be 206)", count);
}

/// Output solution for part 2.
fn part2() {
}

/// Read passports from file
fn read_passports(path: &str) -> Result<Vec<Passport>, Box<dyn error::Error>> {
    let s: String = fs::read_to_string(path).unwrap();
    let mut passports = vec![];
    for block in s.split("\n\n") {
        let line = block.replace("\n", " ");
        let mut names = HashSet::new();
        for field in line.split(" ") {
            if let Some(name) = field.split(":").next() {
                if name != "" {
                    names.insert(name);
                }
            } else {
                let e = format!("invalid input field format [{}]", field);
                return Err(Box::new(io::Error::new(ErrorKind::InvalidInput, e)));
            };
        }
        passports.push(Passport{valid: is_passport_complete(&names)});
    }
    Ok(passports)
}

/// Is list of passport fields complete?
fn is_passport_complete(names: &HashSet<&str>) -> bool {
    // per puzzle, ignore cid
    let expects = vec!["ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt"];
    for expect in expects {
        if !names.contains(expect) {
            return false;
        }
    }
    true
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_passports() {
        let passports = read_passports("input/example1.txt").unwrap();
        assert_eq!(2, passports.into_iter().filter(|p| p.valid ).count());
    }
}
