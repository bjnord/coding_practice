use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<SeatLayout> = result::Result<SeatLayout, Box<dyn error::Error>>;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Seat {
    Floor,
    Empty,
    Occupied,
}

#[derive(Debug)]
pub struct SeatLayout {
    grid: Vec<Seat>,
    height: usize,
    width: usize,
}

impl Seat {
    /// Construct seat from input character.
    #[must_use]
    pub fn from_char(seat: char) -> Seat {
        match seat {
            '.' => Seat::Floor,
            'L' => Seat::Empty,
            '#' => Seat::Occupied,
            _ => {
                let e = format!("invalid seat character {}", seat);
                panic!(e);
            }
        }
    }
}

impl FromStr for SeatLayout {
    type Err = Box<dyn error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let width = input.lines().next().unwrap().len();
        let grid: Vec<Seat> = input
            .lines()
            .flat_map(|line| line.chars().map(Seat::from_char))
            .collect();
        let height = grid.len() / width;
        Ok(Self { grid, height, width })
    }
}

impl SeatLayout {
    /// Construct by reading layout from path. The file should have one
    /// integer per line.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid integer format.
    pub fn read_from_file(path: &str) -> Result<SeatLayout> {
        let s: String = fs::read_to_string(path)?;
        s.parse()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let layout = SeatLayout::read_from_file("input/exampleT.txt")
            .unwrap();
        assert_eq!(2, layout.height);
        assert_eq!(3, layout.width);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let layout = SeatLayout::read_from_file("input/example99.txt");
        assert!(layout.is_err());
    }

    #[test]
    #[should_panic]
    fn test_read_from_file_bad_file() {
        let _layout = SeatLayout::read_from_file("input/bad1.txt");
    }

    #[test]
    fn test_seat_from_char() {
        assert_eq!(Seat::Floor, Seat::from_char('.'));
        assert_eq!(Seat::Empty, Seat::from_char('L'));
        assert_eq!(Seat::Occupied, Seat::from_char('#'));
    }

    #[test]
    #[should_panic]
    fn test_seat_from_bad_char() {
        let _char = Seat::from_char('?');
    }
}
