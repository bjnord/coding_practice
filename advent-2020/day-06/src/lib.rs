#![warn(clippy::pedantic)]

use std::collections::HashMap;
use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Group> = result::Result<Group, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
pub struct Group {
    any_answers: String,
    all_answers: String,
}

impl FromStr for Group {
    type Err = Box<dyn error::Error>;

    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let group: Group = "abcx\nabcy\nabcz\n".parse().unwrap();
    /// assert_eq!(6, group.any_yes_answers());
    /// assert_eq!(3, group.all_yes_answers());
    /// ```
    fn from_str(block: &str) -> Result<Self> {
        let grid: Vec<Vec<char>> = block
            .lines()
            .map(|line| line.chars().collect())
            .collect();
        let people: usize = grid.len();
        let answers: Vec<char> = grid
            .into_iter()
            .flatten()
            .collect();
        let hm: HashMap<char, usize> = answers
            .into_iter()
            .fold(HashMap::new(), |mut acc, c| {
                *acc.entry(c).or_insert(0) += 1;
                acc
            });
        let any_answers: Vec<char> = hm.keys().cloned().collect();
        let all_answers: Vec<char> = hm
            .keys()
            .filter(|k|
                match hm.get(k) {
                    Some(&v) => v >= people,
                    None => false,
                }
            )
            .cloned()
            .collect();
        Ok(Group { any_answers: any_answers.into_iter().collect(), all_answers: all_answers.into_iter().collect() })
    }
}

impl Group {
    /// Return count of questions to which ANY person in the group answered
    /// "yes".
    #[must_use]
    pub fn any_yes_answers(&self) -> usize {
        self.any_answers.len()
    }

    /// Return count of questions to which ALL people in the group answered
    /// "yes".
    #[must_use]
    pub fn all_yes_answers(&self) -> usize {
        self.all_answers.len()
    }

    /// Read groups from a file.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let groups = Group::read_from_file("input/example1.txt").unwrap();
    /// let count_any: usize = groups.iter().map(Group::any_yes_answers).sum();
    /// assert_eq!(11, count_any);
    /// let count_all: usize = groups.iter().map(Group::all_yes_answers).sum();
    /// assert_eq!(6, count_all);
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
