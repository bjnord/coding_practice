use std::error;
use std::fs::File;
use std::io::{self, BufRead, BufReader, ErrorKind};
use lazy_static::lazy_static;
use regex::Regex;
use std::time::Instant;

#[derive(Debug, Clone, PartialEq)]
struct Password {
    min: usize,
    max: usize,
    letter: char,
    password: String,
}

impl Password {
    /// Construct by parsing input line.
    ///
    /// The line is in the form `M-N L: password` where
    /// - `M` is the minimum count (integer)
    /// - `N` is the maximum count (integer)
    /// - `L` is the letter (char)
    /// - `password` is the password (string)
    fn from_input_line(line: String) -> Result<Password, io::Error> {
        lazy_static! {
            static ref RE: Regex = Regex::new(r"(?x)^
                (?P<min>\d+)-
                (?P<max>\d+)\s+
                (?P<letter>[a-z]):\s+
                (?P<password>[a-z]+)
                $").unwrap();
        }
        let cap = match RE.captures(&line) {
            Some(cap) => cap,
            None => {
                let e = format!("invalid input line format [{}]", line);
                return Err(io::Error::new(ErrorKind::InvalidInput, e));
            },
        };
        // FIXME handle ParseIntError for min and max
        let min = String::from(cap.name("min").unwrap().as_str()).parse::<usize>().unwrap();
        let max = String::from(cap.name("max").unwrap().as_str()).parse::<usize>().unwrap();
        let letter = cap.name("letter").unwrap().as_str().chars().next().unwrap();
        let password = String::from(cap.name("password").unwrap().as_str());
        if min > max {
            let e = format!("min > max on input line [{}]", line);
            return Err(io::Error::new(ErrorKind::InvalidInput, e));
        }
        Ok(Password{min, max, letter, password})
    }

    /// Is this password valid according to the given policy?
    fn is_valid(&self) -> bool {
        let matches = self.password
            .chars()
            .filter(|c| *c == self.letter)
            .count();
        matches >= self.min && matches <= self.max
    }
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
    let passwords = read_passwords("input/input.txt").unwrap();
    let count = count_valid_passwords(passwords);
    println!("== PART 1 ==");
    println!("file contains {} valid passwords (should be 393)", count);
}

/// Output solution for part 2.
fn part2() {
}

/// Read passwords from `filename`.
fn read_passwords(filename: &str) -> Result<Vec<Password>, Box<dyn error::Error>> {
    let reader = BufReader::new(File::open(filename)?);
    let res: Result<Vec<Password>, io::Error> = reader
        .lines()
        .map(|line| Password::from_input_line(line.unwrap()))
        .collect();
    match res {
        Ok(vec) => Ok(vec),
        Err(e) => Err(Box::new(e)),
    }
}

/// Return count of valid `passwords`.
fn count_valid_passwords(passwords: Vec<Password>) -> usize {
    passwords.iter()
        .filter(|&p| p.is_valid())
        .count()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_password() {
        let password = Password{min: 1, max: 3, letter: 'a', password: String::from("abcde")};
        assert!(password.is_valid());
    }

    #[test]
    fn test_invalid_password() {
        let password = Password{min: 1, max: 3, letter: 'b', password: String::from("cdefg")};
        assert!(!password.is_valid());
    }

    #[test]
    fn test_read_passwords() {
        let passwords = read_passwords("input/example1.txt").unwrap();
        assert_eq!(3, passwords.len());
        assert_eq!(Password{min: 1, max: 3, letter: 'a', password: String::from("abcde")}, passwords[0]);
        assert_eq!(Password{min: 1, max: 3, letter: 'b', password: String::from("cdefg")}, passwords[1]);
        assert_eq!(Password{min: 2, max: 9, letter: 'c', password: String::from("ccccccccc")}, passwords[2]);
    }

    #[test]
    fn test_count_valid_passwords() {
        let passwords = read_passwords("input/example1.txt").unwrap();
        assert_eq!(2, count_valid_passwords(passwords));
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
}
