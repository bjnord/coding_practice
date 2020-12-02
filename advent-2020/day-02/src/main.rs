use std::error;
use std::fs::File;
use std::io::{self, BufRead, BufReader, ErrorKind};
use lazy_static::lazy_static;
use regex::Regex;
use std::time::Instant;

#[derive(Debug, Clone, PartialEq)]
struct Password {
    first: usize,
    second: usize,
    letter: char,
    password: String,
}

impl Password {
    /// Construct by parsing input line.
    ///
    /// The line is in the form `F-S L: password` where
    /// - `F` is the first value (integer)
    /// - `S` is the second value (integer)
    /// - `L` is the letter (char)
    /// - `password` is the password (string)
    fn from_input_line(line: String) -> Result<Password, io::Error> {
        lazy_static! {
            static ref RE: Regex = Regex::new(r"(?x)^
                (?P<first>\d+)-
                (?P<second>\d+)\s+
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
        // all these unwrap() are safe, given a matching regex
        let first = String::from(cap.name("first").unwrap().as_str()).parse::<usize>().unwrap();
        let second = String::from(cap.name("second").unwrap().as_str()).parse::<usize>().unwrap();
        let letter = cap.name("letter").unwrap().as_str().chars().next().unwrap();
        let password = String::from(cap.name("password").unwrap().as_str());
        if first > second {
            let e = format!("first > second on input line [{}]", line);
            return Err(io::Error::new(ErrorKind::InvalidInput, e));
        }
        Ok(Password{first, second, letter, password})
    }

    /// Is this password valid according to the "min/max" policy?
    fn is_valid_minmax(&self) -> bool {
        let matches = self.password.matches(self.letter).count();
        matches >= self.first && matches <= self.second
    }

    /// Is this password valid according to the "1st/2nd" policy?
    fn is_valid_1st2nd(&self) -> bool {
        let first = self.password.chars().nth(self.first-1).unwrap_or('\0');
        let second = self.password.chars().nth(self.second-1).unwrap_or('\0');
        // to be valid, first OR second position must match, but not both
        if first == self.letter { second != self.letter } else { second == self.letter }
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
    let count = count_valid_minmax_passwords(passwords);
    println!("== PART 1 ==");
    println!("{} passwords valid according to the \"min/max\" policy (should be 393)", count);
}

/// Output solution for part 2.
fn part2() {
    let passwords = read_passwords("input/input.txt").unwrap();
    let count = count_valid_1st2nd_passwords(passwords);
    println!("== PART 2 ==");
    println!("{} passwords valid according to the \"min/max\" policy (should be 690)", count);
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

/// Return count of `passwords` valid according to the "min/max" policy.
fn count_valid_minmax_passwords(passwords: Vec<Password>) -> usize {
    passwords.iter()
        .filter(|&p| p.is_valid_minmax())
        .count()
}

/// Return count of `passwords` valid according to the "1st/2nd" policy.
fn count_valid_1st2nd_passwords(passwords: Vec<Password>) -> usize {
    passwords.iter()
        .filter(|&p| p.is_valid_1st2nd())
        .count()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_minmax_password() {
        let password = Password{first: 1, second: 3, letter: 'a', password: String::from("abcde")};
        assert!(password.is_valid_minmax());
        let password2 = Password{first: 2, second: 9, letter: 'c', password: String::from("ccccccccc")};
        assert!(password2.is_valid_minmax());
    }

    #[test]
    fn test_invalid_minmax_password() {
        let password = Password{first: 1, second: 3, letter: 'b', password: String::from("cdefg")};
        assert!(!password.is_valid_minmax());
    }

    #[test]
    fn test_valid_1st2nd_password() {
        let password = Password{first: 1, second: 3, letter: 'a', password: String::from("abcde")};
        assert!(password.is_valid_1st2nd());
    }

    #[test]
    fn test_invalid_1st2nd_password() {
        let password = Password{first: 1, second: 3, letter: 'b', password: String::from("cdefg")};
        assert!(!password.is_valid_1st2nd());
        let password2 = Password{first: 2, second: 9, letter: 'c', password: String::from("ccccccccc")};
        assert!(!password2.is_valid_1st2nd());
    }

    #[test]
    fn test_read_passwords() {
        let passwords = read_passwords("input/example1.txt").unwrap();
        assert_eq!(3, passwords.len());
        assert_eq!(Password{first: 1, second: 3, letter: 'a', password: String::from("abcde")}, passwords[0]);
        assert_eq!(Password{first: 1, second: 3, letter: 'b', password: String::from("cdefg")}, passwords[1]);
        assert_eq!(Password{first: 2, second: 9, letter: 'c', password: String::from("ccccccccc")}, passwords[2]);
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
