use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<SeatLayout> = result::Result<SeatLayout, Box<dyn error::Error>>;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum Seat {
    Void,
    Floor,
    Empty,
    Occupied,
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct SeatLayout {
    seats: Vec<Seat>,
    height: i32,
    width: i32,
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

    #[allow(clippy::cast_possible_truncation)]
    #[allow(clippy::cast_possible_wrap)]
    fn from_str(input: &str) -> Result<Self> {
        let width = input.lines().next().unwrap().len() as i32;
        let seats: Vec<Seat> = input
            .lines()
            .flat_map(|line| line.trim().chars().map(Seat::from_char))
            .collect();
        let height = (seats.len() as i32) / width;
        Ok(Self { seats, height, width })
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

    /// Return `Seat` at (y, x).
    #[must_use]
    pub fn seat_at(&self, y: i32, x: i32) -> Seat {
        match (y, x) {
            (y, _) if y < 0 || y >= self.height => Seat::Void,
            (_, x) if x < 0 || x >= self.width => Seat::Void,
            _ => {
                self.seats[self.seats_index(y, x)]
            },
        }
    }

    #[allow(clippy::cast_sign_loss)]
    fn seats_index(&self, y: i32, x: i32) -> usize {
        (y * self.width + x) as usize
    }

    /// Return count of occupied seats.
    #[must_use]
    pub fn occupied_seats(&self) -> usize {
        self.seats.iter().filter(|&s| *s == Seat::Occupied).count()
    }

    /// Return count of occupied seats adjacent to (y, x).
    #[must_use]
    pub fn occupied_seats_at(&self, y: i32, x: i32) -> usize {
        let mut seats: Vec<Seat> = Vec::new();
        for dy in -1..=1 {
            for dx in -1..=1 {
                if dy != 0 || dx != 0 {
                    seats.push(self.seat_at(y + dy, x + dx));
                }
            }
        }
        seats.iter().filter(|&s| *s == Seat::Occupied).count()
    }

    /// Do one round of seat filling.
    // TODO replace this hack string implementation with an enum one
    #[must_use]
    pub fn fill_seats(&self) -> SeatLayout {
        let mut s = String::new();
        for y in 0..self.height {
            for x in 0..self.width {
                match self.seat_at(y, x) {
                    Seat::Floor => {
                        s += ".";
                    },
                    Seat::Empty => {
                        if self.occupied_seats_at(y, x) == 0 {
                            s += "#";
                        } else {
                            s += "L";
                        }
                    },
                    Seat::Occupied => {
                        if self.occupied_seats_at(y, x) >= 4 {
                            s += "L";
                        } else {
                            s += "#";
                        }
                    },
                    Seat::Void => {
                        panic!("(y, x) outside grid bounds")
                    },
                }
            }
            s += "\n";
        }
        s.parse().unwrap()
    }

    /// Do rounds of seat filling, until the seat layout stabilizes.
    #[must_use]
    pub fn fill_seats_until_stable(&self) -> SeatLayout {
        let mut prev_layout = self.fill_seats();
        let mut next_layout = prev_layout.fill_seats();
        while next_layout != prev_layout {
            prev_layout = next_layout.clone();
            next_layout = prev_layout.fill_seats();
        }
        prev_layout
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const TINY_LAYOUT: &'static str = "\
        .#L
        .L.";

    #[test]
    fn test_read_from_file() {
        let layout: SeatLayout = TINY_LAYOUT.parse().unwrap();
        assert_eq!(2, layout.height);
        assert_eq!(3, layout.width);
    }

    #[test]
    fn test_layout_indexing() {
        let layout: SeatLayout = TINY_LAYOUT.parse().unwrap();
        assert_eq!(Seat::Floor, layout.seat_at(1, 2));
        assert_eq!(Seat::Empty, layout.seat_at(0, 2));
        assert_eq!(Seat::Occupied, layout.seat_at(0, 1));
    }

    #[test]
    fn test_layout_indexing_void_y() {
        let layout: SeatLayout = TINY_LAYOUT.parse().unwrap();
        assert_eq!(Seat::Void, layout.seat_at(-1, 2));
        assert_eq!(Seat::Void, layout.seat_at(2, 2));
    }

    #[test]
    fn test_layout_indexing_void_x() {
        let layout: SeatLayout = TINY_LAYOUT.parse().unwrap();
        assert_eq!(Seat::Void, layout.seat_at(1, -1));
        assert_eq!(Seat::Void, layout.seat_at(1, 3));
    }

    #[test]
    fn test_layout_equality() {
        let layout1 = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        let layout_r2 = layout1.fill_seats();
        assert_ne!(layout1, layout_r2);
        let layout3 = SeatLayout::read_from_file("input/example3.txt")
            .unwrap();
        let layout_r3 = layout_r2.fill_seats();
        assert_eq!(layout3, layout_r3);
    }

    #[test]
    fn test_occupied_seats() {
        let layout = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        assert_eq!(0, layout.occupied_seats());
        let layout3 = SeatLayout::read_from_file("input/example3.txt")
            .unwrap();
        assert_eq!(20, layout3.occupied_seats());
    }

    #[test]
    fn test_occupied_seats_at() {
        let layout = SeatLayout::read_from_file("input/example1s.txt")
            .unwrap();
        assert_eq!(1, layout.occupied_seats_at(0, 0));
        assert_eq!(2, layout.occupied_seats_at(4, 0));
        assert_eq!(4, layout.occupied_seats_at(2, 1));
        assert_eq!(0, layout.occupied_seats_at(9, 6));
        assert_eq!(1, layout.occupied_seats_at(9, 9));
    }

    #[test]
    fn test_fill_seats() {
        let layout = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        let layout2 = layout.fill_seats();
        assert_eq!(71, layout2.occupied_seats());
        let layout3 = layout2.fill_seats();
        assert_eq!(20, layout3.occupied_seats());
    }

    #[test]
    fn test_fill_seats_stable() {
        let layout = SeatLayout::read_from_file("input/example1s.txt")
            .unwrap();
        let before_seats = layout.occupied_seats();
        let next_layout = layout.fill_seats();
        assert_eq!(before_seats, next_layout.occupied_seats());
    }

    #[test]
    fn test_fill_seats_until_stable() {
        let layout = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        let layout_rs = layout.fill_seats_until_stable();
        let layout_s = SeatLayout::read_from_file("input/example1s.txt")
            .unwrap();
        assert_eq!(layout_s, layout_rs);
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
