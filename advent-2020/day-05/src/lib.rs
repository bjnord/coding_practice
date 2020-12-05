#![warn(clippy::pedantic)]

use std::error;
use std::fs;
use std::io::{self, ErrorKind};
use std::str::FromStr;

pub struct BoardingPass {
    row: usize,
    column: usize,
}

impl FromStr for BoardingPass {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self, Self::Err> {
        let (row, column, err_char) = line.chars().fold((0, 0, '\0'), |(r, c, ech), ch|
            match ch {
                'F' => (r * 2, c, ech),
                'B' => (r * 2 + 1, c, ech),
                'L' => (r, c * 2, ech),
                'R' => (r, c * 2 + 1, ech),
                _   => (r, c, ch),
            }
        );
        if err_char != '\0' {
            let e = format!("invalid character '{}' in line [{}]", err_char, line);
            return Err(Box::new(io::Error::new(ErrorKind::InvalidInput, e)));
        } else {
            Ok(Self{row, column})
        }
    }
}

impl BoardingPass {
    /// Return boarding pass row number (0-127).
    #[must_use]
    pub fn row(&self) -> usize {
        self.row
    }

    /// Return boarding pass column number (0-7).
    #[must_use]
    pub fn column(&self) -> usize {
        self.column
    }

    /// Return boarding pass seat number (0-1023).
    #[must_use]
    pub fn seat(&self) -> usize {
        self.row * 8 + self.column
    }

    /// Read boarding passes from file.
    pub fn read_from_file(path: &str) -> Result<Vec<BoardingPass>, Box<dyn error::Error>> {
        let s: String = fs::read_to_string(path)?;
        let mut boarding_passes = vec![];
        for block in s.trim_end().split('\n') {
            boarding_passes.push(block.parse()?);
        }
        Ok(boarding_passes)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_example_1() {
        let pass: BoardingPass = "FBFBBFFRLR".parse().unwrap();
        assert_eq!(44, pass.row());
        assert_eq!(5, pass.column());
        assert_eq!(357, pass.seat());
    }

    #[test]
    fn test_parse_example_2() {
        let pass: BoardingPass = "BFFFBBFRRR".parse().unwrap();
        assert_eq!(70, pass.row());
        assert_eq!(7, pass.column());
        assert_eq!(567, pass.seat());
    }

    #[test]
    fn test_parse_example_3() {
        let pass: BoardingPass = "FFFBBBFRRR".parse().unwrap();
        assert_eq!(14, pass.row());
        assert_eq!(7, pass.column());
        assert_eq!(119, pass.seat());
    }

    #[test]
    fn test_parse_example_4() {
        let pass: BoardingPass = "BBFFBBFRLL".parse().unwrap();
        assert_eq!(102, pass.row());
        assert_eq!(4, pass.column());
        assert_eq!(820, pass.seat());
    }

    #[test]
    fn test_parse_bad_character() {
        let result: Result<BoardingPass, _> = "FBMBBFFRLR".parse();
        assert!(result.is_err());
    }

    #[test]
    fn test_read_from_file() {
        let passes = BoardingPass::read_from_file("input/example1.txt").unwrap();
        assert_eq!(4, passes.len());
    }

    #[test]
    fn test_read_from_file_bad_path() {
        let result = BoardingPass::read_from_file("input/example99.txt");
        assert!(result.is_err());
    }
}
