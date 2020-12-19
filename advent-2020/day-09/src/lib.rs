use itertools::Itertools;
use std::collections::VecDeque;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Copy)]
pub struct Entry {
    value: u64,
}

#[derive(Debug)]
pub struct XmasList {
    window: VecDeque<Entry>,
    size: usize,
}

impl FromStr for Entry {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let value: u64 = line.parse()?;
        Ok(Self { value })
    }
}

impl Entry {
    /// Construct XMAS entry from value.
    pub fn from_value(value: u64) -> Entry {
        Entry { value }
    }

    /// Return XMAS entry value.
    #[must_use]
    pub fn value(&self) -> u64 {
        self.value
    }

    /// Read XMAS entries from `path`. The file should have one integer per
    /// line.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid integer format.
    pub fn read_from_file(path: &str) -> Result<Vec<Entry>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }

    /// Are there two (non-contiguous) entries from `entries` whose sum is
    /// `expected`?
    #[must_use]
    pub fn has_sum(entries: &[Entry], expected: Entry) -> bool {
        for combo in entries.iter().map(Entry::value).combinations(2) {
            if combo.iter().sum::<u64>() == expected.value {
                return true;
            }
        }
        false
    }

    /// Find a contiguous set of at least two `entries` whose sum is
    /// `expected`. Return the sum of the smallest and largest values in
    /// these entries.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_09::Entry;
    /// let entries = Entry::read_from_file("input/example2.txt").unwrap();
    /// let sum = Entry::find_sum(&entries, &Entry::from_value(127)).unwrap();
    /// assert_eq!(62, sum);
    /// ```
    #[must_use]
    pub fn find_sum(entries: &[Entry], expected: &Entry) -> Option<u64> {
        for n in 2..100 {
            let mut values: Vec<u64> = vec![0u64; n];
            for value in entries.iter().map(Entry::value) {
                values = values[1..].to_vec();
                values.push(value);
                if values.iter().sum::<u64>() == expected.value() {
                    return Some(values.iter().min().unwrap() + values.iter().max().unwrap());
                }
            }
        }
        None
    }
}

impl XmasList {
    /// Construct new XMAS list of the given size.
    #[must_use]
    pub fn build(size: usize) -> XmasList {
        XmasList { window: VecDeque::new(), size }
    }

    /// Return XMAS entries currently in window.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_09::{Entry, XmasList};
    /// let mut xlist = XmasList::build(2);
    /// xlist.push(Entry::from_value(4));
    /// xlist.push(Entry::from_value(9));
    /// xlist.push(Entry::from_value(5));
    /// assert!([9, 5].iter().zip(xlist.window_entries()).all(|(a, b)| *a == b.value()));
    /// ```
    #[must_use]
    pub fn window_entries(&self) -> Vec<Entry> {
        self.window.iter().copied().collect()
    }

    /// Push XMAS entry onto end of list. The list will grow up to its
    /// specified size, at which point pushing will pop entry off beginning
    /// of list (FIFO) to retain its size.
    pub fn push(&mut self, entry: Entry) {
        self.window.push_back(entry);
        if self.window.len() > self.size {
            self.window.pop_front();
        }
    }

    /// Find the first XMAS entry beyond the preamble `size` which is not
    /// a sum of two entries in the current window.
    ///
    /// Examples
    ///
    /// ```
    /// # use day_09::{Entry, XmasList};
    /// let entries = Entry::read_from_file("input/example1.txt").unwrap();
    /// let entry = XmasList::find_first_nonsum(&entries, 25);
    /// assert_eq!(65, entry.unwrap().value());
    /// ```
    #[must_use]
    pub fn find_first_nonsum(entries: &[Entry], size: usize) -> Option<Entry> {
        let mut xlist = Self::build(size);
        for (i, entry) in entries.iter().enumerate() {
            if i < size {
                xlist.push(*entry);
            } else {
                if !Entry::has_sum(&xlist.window_entries(), *entry) {
                    return Some(*entry);
                }
                xlist.push(*entry);
            }
        }
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let values: Vec<u64> = Entry::read_from_file("input/example0.txt")
            .unwrap()
            .iter()
            .map(Entry::value)
            .collect();
        assert_eq!(vec![1721, 979, 366, 299, 675, 1456], values);
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
    fn test_has_sum() {
        let entries = Entry::read_from_file("input/example1.txt").unwrap();
        let entries = entries[0..25].to_vec();
        assert_eq!(true, Entry::has_sum(&entries, Entry { value: 45 }));
        assert_eq!(false, Entry::has_sum(&entries, Entry { value: 65 }));
    }

    #[test]
    fn test_has_sum_none() {
        let entries: Vec<Entry> = vec![1, 2, 3, 4, 5]
            .into_iter()
            .map(|value| Entry { value })
            .collect();
        if Entry::has_sum(&entries, Entry { value: 2001 }) {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_find_first_nonsum_2() {
        let entries = Entry::read_from_file("input/example2.txt").unwrap();
        let entry = XmasList::find_first_nonsum(&entries, 5);
        assert_eq!(127, entry.unwrap().value());
    }
}
