#![warn(clippy::pedantic)]

use day_04::Passport;
use std::error;
use std::fs;
use std::time::Instant;

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
    let count = passports.into_iter().filter(Passport::is_complete).count();
    println!("== PART 1 ==");
    println!("{} passports are complete (should be 206)", count);
}

/// Output solution for part 2.
fn part2() {
    let passports = read_passports("input/input.txt").unwrap();
    let count = passports.into_iter().filter(Passport::is_valid).count();
    println!("== PART 2 ==");
    println!("{} passports are valid (should be 123)", count);
}

/// Read passports from file
fn read_passports(path: &str) -> Result<Vec<Passport>, Box<dyn error::Error>> {
    let s: String = fs::read_to_string(path).unwrap();
    let mut passports = vec![];
    for block in s.split("\n\n") {
        passports.push(block.parse()?);
    }
    Ok(passports)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_passports() {
        let passports = read_passports("input/example1.txt").unwrap();
        assert_eq!(2, passports.into_iter().filter(|p| p.is_valid() ).count());
    }

    #[test]
    fn test_read_passports2() {
        let passports = read_passports("input/example2.txt").unwrap();
        assert_eq!(4, passports.into_iter().filter(|p| p.is_valid() ).count());
    }
}
