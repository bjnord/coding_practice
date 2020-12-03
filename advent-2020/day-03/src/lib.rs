#![warn(clippy::pedantic)]

use std::error;
use std::fs::File;
use std::io::{BufRead, BufReader};

pub struct Forest {
    width: usize,
    height: usize,
    terrain: String,
}

impl Forest {
    /// Construct from input file.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened.
    pub fn from_input_file(path: &str) -> Result<Forest, Box<dyn error::Error>> {
        let reader = BufReader::new(File::open(path)?);
        let mut width = 0;
        let mut height = 0;
        let mut terrain = String::new();
        for line in reader.lines() {
            let s = line.unwrap();
            height += 1;
            width = s.len();
            terrain.push_str(&s);
        }
        Ok(Forest{width, height, terrain})
    }

    /// Return height of terrain map.
    #[must_use]
    pub fn height(&self) -> usize {
        self.height
    }

    /// Is there a tree at position [y, x]?
    #[must_use]
    pub fn is_tree_at(&self, y: usize, x: usize) -> bool {
        if y >= self.height {
            panic!("y > terrain map height");
        }
        let x0 = x % self.width;
        let pos = y * self.width + x0;
        let b = self.terrain.as_bytes()[pos];
        b == b'#'
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_construct_from_input_file() {
        let forest = Forest::from_input_file("input/example1.txt").unwrap();
        assert_eq!(11, forest.width);
        assert_eq!(11, forest.height);
        assert_eq!(121, forest.terrain.len());
    }

    #[test]
    fn test_is_tree_at_false() {
        let forest = Forest::from_input_file("input/example1.txt").unwrap();
        assert_eq!(false, forest.is_tree_at(0, 0));
        assert_eq!(false, forest.is_tree_at(2, 0));
        assert_eq!(false, forest.is_tree_at(2, 3));
    }

    #[test]
    fn test_is_tree_at_true() {
        let forest = Forest::from_input_file("input/example1.txt").unwrap();
        assert_eq!(true, forest.is_tree_at(0, 2));
        assert_eq!(true, forest.is_tree_at(3, 2));
        assert_eq!(true, forest.is_tree_at(10, 10));
    }
}
