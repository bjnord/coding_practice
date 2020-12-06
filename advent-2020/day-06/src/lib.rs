#![warn(clippy::pedantic)]

#[macro_use] extern crate maplit;

use std::collections::HashMap;
use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Group> = result::Result<Group, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
pub struct Group {
    any_answers: usize,
    all_answers: usize,
}

impl FromStr for Group {
    type Err = Box<dyn error::Error>;

    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let group: Group = "abcx\nabcy\nabcz\n".parse().unwrap();
    /// assert_eq!(6, group.any_answers());
    /// assert_eq!(3, group.all_answers());
    /// ```
    fn from_str(block: &str) -> Result<Self> {
        let hm: HashMap<char, usize> = block
            .trim()
            .chars()
            .fold(hashmap!{'\n' => 0}, |mut acc, c| {
                *acc.entry(c).or_insert(0) += 1;
                acc
            });
        let people: usize = match hm.get(&'\n') {
            Some(n) => n + 1,
            None => 1,
        };
        let any_answers = hm.len() - 1;  // ignore '\n'
        let all_answers = hm
            .keys()
            .filter(|k|
                match hm.get(k) {
                    Some(&v) => (v >= people) && k.is_alphabetic(),
                    None => false,
                }
            )
            .count();
        Ok(Group { any_answers, all_answers })
    }
}

impl Group {
    /// Return count of questions to which ANY person in the group answered
    /// "yes".
    #[must_use]
    pub fn any_answers(&self) -> usize {
        self.any_answers
    }

    /// Return count of questions to which ALL people in the group answered
    /// "yes".
    #[must_use]
    pub fn all_answers(&self) -> usize {
        self.all_answers
    }

    /// Read groups from a file.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let groups = Group::read_from_file("input/example1.txt").unwrap();
    /// let count_any: usize = groups.iter().map(Group::any_answers).sum();
    /// assert_eq!(11, count_any);
    /// let count_all: usize = groups.iter().map(Group::all_answers).sum();
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
