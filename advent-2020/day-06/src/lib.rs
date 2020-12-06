#![warn(clippy::pedantic)]

use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Group> = result::Result<Group, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
pub struct Group {
    answers: String,
}

impl FromStr for Group {
    type Err = Box<dyn error::Error>;

    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let group: Group = "abcx\nabcy\nabcz\n".parse().unwrap();
    /// assert_eq!(6, group.yes_answers());
    /// ```
    fn from_str(block: &str) -> Result<Self> {
        let grid: Vec<Vec<char>> = block
            .lines()
            .map(|line| line.chars().collect())
            .collect();
        let mut answers: Vec<char> = grid
            .into_iter()
            .flatten()
            .collect();
        answers.sort();
        answers.dedup();
        Ok(Group { answers: answers.into_iter().collect() })
    }
}

impl Group {
    /// Return count of questions with "yes" answers from this group.
    #[must_use]
    pub fn yes_answers(&self) -> usize {
        self.answers.len()
    }

    /// Read groups from a file.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let groups = Group::read_from_file("input/example1.txt").unwrap();
    /// let count: usize = groups.iter().map(Group::yes_answers).sum();
    /// assert_eq!(11, count);
    /// ```
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened.
    pub fn read_from_file(path: &str) -> Result<Vec<Group>> {
        let s: String = fs::read_to_string(path)?;
        s.split("\n\n").map(str::parse).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file_bad_path() {
        let result = Group::read_from_file("input/example99.txt");
        assert!(result.is_err());
    }
}
