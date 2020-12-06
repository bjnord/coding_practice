#![warn(clippy::pedantic)]

use day_02::Password;
use std::error;
use std::fs::File;
use std::io::{self, BufRead, BufReader};
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let passwords = read_passwords("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = count_valid_minmax_passwords(passwords);
    let run_time = start.elapsed() - gen_time;
    println!("Day 2 - Part 1 : {} <=> 393 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let passwords = read_passwords("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = count_valid_1st2nd_passwords(passwords);
    let run_time = start.elapsed() - gen_time;
    println!("Day 2 - Part 2 : {} <=> 690 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Read passwords from `filename`.
fn read_passwords(filename: &str) -> Result<Vec<Password>, Box<dyn error::Error>> {
    let reader = BufReader::new(File::open(filename)?);
    let res: Result<Vec<Password>, io::Error> = reader
        .lines()
        .map(|line| Password::from_input_line(&line.unwrap()))
        .collect();
    match res {
        Ok(vec) => Ok(vec),
        Err(e) => Err(Box::new(e)),
    }
}

/// Return count of `passwords` valid according to the "min/max" policy.
fn count_valid_minmax_passwords(passwords: Vec<Password>) -> usize {
    passwords.into_iter()
        .filter(Password::is_valid_minmax)
        .count()
}

/// Return count of `passwords` valid according to the "1st/2nd" policy.
fn count_valid_1st2nd_passwords(passwords: Vec<Password>) -> usize {
    passwords.into_iter()
        .filter(Password::is_valid_1st2nd)
        .count()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_passwords() {
        let passwords = read_passwords("input/example1.txt").unwrap();
        assert_eq!(3, passwords.len());
    }

    #[test]
    fn test_read_passwords_no_file() {
        let passwords = read_passwords("input/example99.txt");
        assert!(passwords.is_err());
    }

    #[test]
    fn test_read_passwords_bad_file_format() {
        let passwords = read_passwords("input/bad1.txt");
        assert!(passwords.is_err());
    }

    #[test]
    fn test_read_passwords_invalid_fields() {
        let passwords = read_passwords("input/bad2.txt");
        assert!(passwords.is_err());
    }

    #[test]
    fn test_count_valid_minmax_passwords() {
        let passwords = read_passwords("input/example1.txt").unwrap();
        assert_eq!(2, count_valid_minmax_passwords(passwords));
    }

    #[test]
    fn test_count_valid_1st2nd_passwords() {
        let passwords = read_passwords("input/example1.txt").unwrap();
        assert_eq!(1, count_valid_1st2nd_passwords(passwords));
    }
}
