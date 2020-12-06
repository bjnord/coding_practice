#![warn(clippy::pedantic)]

use custom_error::custom_error;
use itertools::Itertools;
use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

pub const ENTRY_SUM: i32 = 2020;

type Result<Entry> = result::Result<Entry, Box<dyn error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub SolutionError
    NotFound{expected: i32} = "no solution found for {expected}"
}

#[derive(Debug, Clone)]
pub struct Entry {
    amount: i32,
}

impl FromStr for Entry {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let amount: i32 = line.parse()?;
        Ok(Self { amount })
    }
}

impl Entry {
    /// Return expense report entry amount.
    #[must_use]
    pub fn amount(&self) -> i32 {
        self.amount
    }

    /// Read expense report entries from `path`. The file should have one
    /// integer per line.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid boarding pass format.
    pub fn read_from_file(path: &str) -> Result<Vec<Entry>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }

    /// Find `n` amounts from `entries` whose sum is `expected`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if a solution cannot be found.
    pub fn find_solution(entries: &[Entry], n: usize, expected: i32) -> Result<Vec<i32>> {
        for combo in entries.iter().map(Entry::amount).combinations(n) {
            if combo.iter().sum::<i32>() == expected {
                return Ok(combo);
            }
        }
        Err(SolutionError::NotFound { expected }.into())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let amounts: Vec<i32> = Entry::read_from_file("input/example1.txt")
            .unwrap()
            .iter()
            .map(Entry::amount)
            .collect();
        assert_eq!(vec![1721, 979, 366, 299, 675, 1456], amounts);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let entries = Entry::read_from_file("input/example99.txt");
        assert!(entries.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let entries = Entry::read_from_file("input/bad1.txt");
        assert!(entries.is_err());
    }

    #[test]
    fn test_find_solution_for_2() {
        let entries = Entry::read_from_file("input/example1.txt").unwrap();
        let solution = Entry::find_solution(&entries, 2, ENTRY_SUM).unwrap();
        let prod = solution.iter().product::<i32>();
        assert_eq!(2, solution.len());
        assert_eq!(514579, prod);
    }

    #[test]
    fn test_find_solution_for_3() {
        let entries = Entry::read_from_file("input/example1.txt").unwrap();
        let solution = Entry::find_solution(&entries, 3, ENTRY_SUM).unwrap();
        let prod = solution.iter().product::<i32>();
        assert_eq!(3, solution.len());
        assert_eq!(241861950, prod);
    }

    #[test]
    fn test_no_solution_found() {
        let entries: Vec<Entry> = vec![1, 2, 3, 4, 5]
            .into_iter()
            .map(|amount| Entry { amount })
            .collect();
        let result = Entry::find_solution(&entries, 2, ENTRY_SUM);
        assert!(result.is_err());
    }
}
