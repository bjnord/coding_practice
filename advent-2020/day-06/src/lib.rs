#[macro_use] extern crate maplit;

use std::collections::HashMap;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug)]
pub struct Group {
    answers: HashMap<char, u32>,
    people: u32,
}

impl FromStr for Group {
    type Err = Box<dyn std::error::Error>;

    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let group: Group = "abcx\nabcy\nabz\n".parse().unwrap();
    /// assert_eq!(3, group.people());
    /// ```
    fn from_str(block: &str) -> Result<Self> {
        let mut answers: HashMap<char, u32> = block
            .trim()
            .chars()
            .fold(hashmap!{'\n' => 0}, |mut acc, c| {
                *acc.entry(c).or_insert(0) += 1;
                acc
            });
        let people: u32 = match answers.get(&'\n') {
            Some(n) => n + 1,
            None => 1,
        };
        answers.remove(&'\n');
        Ok(Group { answers, people })
    }
}

impl Group {
    /// Return count of people in the group.
    #[must_use]
    pub fn people(&self) -> u32 {
        self.people
    }

    /// Return count of questions to which ANY person in the group answered
    /// "yes".
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let group: Group = "abcx\nabcy\nabz\n".parse().unwrap();
    /// assert_eq!(6, group.any_answers());
    /// ```
    #[must_use]
    #[allow(clippy::cast_possible_truncation)]
    pub fn any_answers(&self) -> u32 {
        self.answers.len() as u32
    }

    /// Return count of questions to which ALL people in the group answered
    /// "yes".
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let group: Group = "abcx\nabcy\nabz\n".parse().unwrap();
    /// assert_eq!(2, group.all_answers());
    /// ```
    #[must_use]
    #[allow(clippy::cast_possible_truncation)]
    pub fn all_answers(&self) -> u32 {
        self.answers
            .keys()
            .filter(|k|
                match self.answers.get(k) {
                    Some(&v) => (v >= self.people) && k.is_alphabetic(),
                    None => false,
                }
            )
            .count() as u32
    }

    /// Read groups from a file.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_06::Group;
    /// let groups = Group::read_from_file("input/example1.txt").unwrap();
    /// assert_eq!(5, groups.len());
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

    #[test]
    fn test_example1_any_answers() {
        let groups = Group::read_from_file("input/example1.txt").unwrap();
        let count_any = groups.iter().map(Group::any_answers).sum::<u32>();
        assert_eq!(11, count_any);
    }

    #[test]
    fn test_example1_all_answers() {
        let groups = Group::read_from_file("input/example1.txt").unwrap();
        let count_all = groups.iter().map(Group::all_answers).sum::<u32>();
        assert_eq!(6, count_all);
    }
}
