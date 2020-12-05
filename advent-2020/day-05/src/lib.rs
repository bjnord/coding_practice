#![warn(clippy::pedantic)]

use itertools::Itertools;
use std::error;
use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<BoardingPass> = result::Result<BoardingPass, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct BoardingPassError(String);

impl fmt::Display for BoardingPassError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Boarding pass error: {}", self.0)
    }
}

impl error::Error for BoardingPassError {}

#[derive(Debug, Clone)]
pub struct BoardingPass {
    row: usize,
    column: usize,
}

impl FromStr for BoardingPass {
    type Err = Box<dyn error::Error>;

    /// # Examples
    ///
    /// ```
    /// # use day_05::BoardingPass;
    /// let pass: BoardingPass = "FBFBBFFRLR".parse().unwrap();
    /// assert_eq!(44, pass.row());
    /// assert_eq!(5, pass.column());
    /// assert_eq!(357, pass.seat());
    /// ```
    fn from_str(line: &str) -> Result<Self> {
        let (row, column, err_char) = line.chars().fold((0, 0, '\0'), |(r, c, ech), ch|
            match ch {
                'F' => (r * 2, c, ech),
                'B' => (r * 2 + 1, c, ech),
                'L' => (r, c * 2, ech),
                'R' => (r, c * 2 + 1, ech),
                _   => (r, c, ch),
            }
        );
        if err_char == '\0' {
            Ok(Self{row, column})
        } else {
            let e = format!("invalid character '{}' in line [{}]", err_char, line);
            Err(BoardingPassError(e).into())
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
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_05::BoardingPass;
    /// let passes = BoardingPass::read_from_file("input/example1.txt").unwrap();
    /// assert_eq!(4, passes.len());
    /// ```
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if
    /// a line is found with an invalid boarding pass format.
    pub fn read_from_file(path: &str) -> Result<Vec<BoardingPass>> {
        let s: String = fs::read_to_string(path)?;
        let mut boarding_passes = vec![];
        for line in s.lines() {
            boarding_passes.push(line.parse()?);
        }
        Ok(boarding_passes)
    }

    /// Find the highest seat ID on any boarding pass.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_05::BoardingPass;
    /// let passes = BoardingPass::read_from_file("input/example1.txt").unwrap();
    /// assert_eq!(Some(820), BoardingPass::max_seat(&passes));
    /// ```
    #[must_use]
    pub fn max_seat(passes: &[BoardingPass]) -> Option<usize> {
        passes.iter().map(BoardingPass::seat).max()
    }

    /// Find the seat ID with no boarding pass.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_05::BoardingPass;
    /// # // this file (not in order) has:
    /// # // - row 0: empty
    /// # // - row 1: full
    /// # // - row 2: one empty seat in column 3
    /// # // - row 3: full
    /// # // 2 * 8 + 3 = 19
    /// let passes = BoardingPass::read_from_file("input/example2.txt").unwrap();
    /// assert_eq!(Some(19), BoardingPass::empty_seat(&passes));
    /// ```
    #[must_use]
    pub fn empty_seat(passes: &[BoardingPass]) -> Option<usize> {
        match passes.iter()
                .sorted_by_key(|p| p.seat())
                .tuple_windows()
                .find(|(a, b)| b.seat() - a.seat() == 2) {
            Some((a, _b)) => Some(a.seat() + 1),
            None => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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
        let result: Result<BoardingPass> = "FBMBBFFRLR".parse();
        assert!(result.is_err());
    }

    #[test]
    fn test_read_from_file_bad_path() {
        let result = BoardingPass::read_from_file("input/example99.txt");
        assert!(result.is_err());
    }
    #[test]
    fn test_max_seat_empty_list() {
        let passes: Vec<BoardingPass> = vec![];
        assert_eq!(None, BoardingPass::max_seat(&passes));
    }
}
