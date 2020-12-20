use std::convert::TryFrom;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

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

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum FillRules {
    Stringent,
    Tolerant,
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
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let width = i32::try_from(input.lines().next().unwrap().len()).unwrap();
        let seats: Vec<Seat> = input
            .lines()
            .flat_map(|line| line.trim().chars().map(Seat::from_char))
            .collect();
        let height = i32::try_from(seats.len()).unwrap() / width;
        Ok(Self { seats, height, width })
    }
}

impl fmt::Display for SeatLayout {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for y in 0..self.height {
            for x in 0..self.width {
                s += match self.seat_at(y, x) {
                    Seat::Floor => ".",
                    Seat::Empty => "L",
                    Seat::Occupied => "#",
                    Seat::Void => panic!("unexpected Void in Display"),
                };
            }
            s += "\n";
        }
        write!(f, "{}", s)
    }
}

pub struct SeatLayoutIter {
    layout: SeatLayout,
    rules: FillRules,
}

impl Iterator for SeatLayoutIter {
    type Item = SeatLayout;

    fn next(&mut self) -> Option<Self::Item> {
        let prev_layout = self.layout.clone();
        self.layout = prev_layout.fill_seats(self.rules);
        if self.layout == prev_layout { None } else { Some(self.layout.clone()) }
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

    #[must_use]
    pub fn iter(&self, rules: FillRules) -> SeatLayoutIter {
        SeatLayoutIter {
            layout: self.clone(),
            rules,
        }
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

    fn seats_index(&self, y: i32, x: i32) -> usize {
        usize::try_from(y * self.width + x).unwrap()
    }

    /// Return count of occupied seats.
    #[must_use]
    pub fn occupied_seats(&self) -> usize {
        self.seats.iter().filter(|&s| *s == Seat::Occupied).count()
    }

    /// Return count of occupied seats visible from `(y, x)` with radius
    /// `r`. Using `r=1` returns only occupied seats immediately adjacent
    /// to `(y, x)`.
    #[must_use]
    pub fn visible_occupied_seats_at(&self, y: i32, x: i32, r: i32) -> usize {
        if r < 1 {
            panic!("radius must be greater than 0");
        }
        let mut n_occ_seats: usize = 0;
        for dy in -1..=1 {
            for dx in -1..=1 {
                if dy == 0 && dx == 0 {
                    continue;
                }
                for i in 1..=r {
                    let seat = self.seat_at(y + dy * i, x + dx * i);
                    if seat == Seat::Occupied {
                        n_occ_seats += 1;
                    }
                    if seat != Seat::Floor {
                        break;
                    }
                }
            }
        }
        n_occ_seats
    }

    /// Do one round of seat filling, according to the specified `rules`.
    #[must_use]
    pub fn fill_seats(&self, rules: FillRules) -> SeatLayout {
        let (occ_limit, r) = match rules {
            FillRules::Stringent => (4, 1),
            FillRules::Tolerant => (5, i32::MAX),
        };
        let mut seats = Vec::<Seat>::new();
        for y in 0..self.height {
            for x in 0..self.width {
                seats.push(self.new_seat_at(y, x, occ_limit, r));
            }
        }
        SeatLayout { seats, height: self.height, width: self.width }
    }

    fn new_seat_at(&self, y: i32, x: i32, occ_limit: usize, r: i32) -> Seat {
        match self.seat_at(y, x) {
            Seat::Floor => { Seat::Floor },
            Seat::Empty => {
                if self.visible_occupied_seats_at(y, x, r) == 0 {
                    Seat::Occupied
                } else {
                    Seat::Empty
                }
            },
            Seat::Occupied => {
                if self.visible_occupied_seats_at(y, x, r) >= occ_limit {
                    Seat::Empty
                } else {
                    Seat::Occupied
                }
            },
            Seat::Void => { panic!("(y, x) outside grid bounds") },
        }
    }

    /// Do rounds of seat filling, according to the specified `rules`,
    /// until the seat layout stabilizes.
    #[must_use]
    pub fn fill_seats_until_stable(&self, rules: FillRules) -> SeatLayout {
        let mut prev_layout = self.clone();
        let mut layout = prev_layout.fill_seats(rules);
        while layout != prev_layout {
            prev_layout = layout;
            layout = prev_layout.fill_seats(rules);
        }
        layout
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
        let layout_r2 = layout1.fill_seats(FillRules::Stringent);
        assert_ne!(layout1, layout_r2);
        let layout3 = SeatLayout::read_from_file("input/example3.txt")
            .unwrap();
        let layout_r3 = layout_r2.fill_seats(FillRules::Stringent);
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
    fn test_visible_occupied_seats_at_adjacent() {
        let layout = SeatLayout::read_from_file("input/example1s.txt")
            .unwrap();
        assert_eq!(1, layout.visible_occupied_seats_at(0, 0, 1));
        assert_eq!(2, layout.visible_occupied_seats_at(4, 0, 1));
        assert_eq!(4, layout.visible_occupied_seats_at(2, 1, 1));
        assert_eq!(0, layout.visible_occupied_seats_at(9, 6, 1));
        assert_eq!(1, layout.visible_occupied_seats_at(9, 9, 1));
    }

    #[test]
    fn test_fill_seats_stringent() {
        let layout = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        let layout2 = layout.fill_seats(FillRules::Stringent);
        assert_eq!(71, layout2.occupied_seats());
        let layout3 = layout2.fill_seats(FillRules::Stringent);
        assert_eq!(20, layout3.occupied_seats());
    }

    #[test]
    fn test_fill_seats_stringent_stable() {
        let layout = SeatLayout::read_from_file("input/example1s.txt")
            .unwrap();
        let before_seats = layout.occupied_seats();
        let next_layout = layout.fill_seats(FillRules::Stringent);
        assert_eq!(before_seats, next_layout.occupied_seats());
    }

    #[test]
    fn test_fill_seats_stringent_until_stable() {
        let layout = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        let layout_rs = layout.fill_seats_until_stable(FillRules::Stringent);
        let layout_s = SeatLayout::read_from_file("input/example1s.txt")
            .unwrap();
        assert_eq!(layout_s, layout_rs);
        assert_eq!(37, layout_rs.occupied_seats());
    }

    #[test]
    fn test_fill_seats_tolerant_until_stable() {
        let layout = SeatLayout::read_from_file("input/example1.txt")
            .unwrap();
        let layout_rs = layout.fill_seats_until_stable(FillRules::Tolerant);
        let layout_s = SeatLayout::read_from_file("input/example1s-tol.txt")
            .unwrap();
        assert_eq!(layout_s, layout_rs);
        assert_eq!(26, layout_rs.occupied_seats());
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

    #[test]
    fn test_visible_occupied_seats_at() {
        let layout = SeatLayout::read_from_file("input/vexample1.txt")
            .unwrap();
        assert_eq!(8, layout.visible_occupied_seats_at(4, 3, i32::MAX));
    }

    const VIS_ROW_LAYOUT: &'static str = "\
        .............
        .L.L.#.#.#.#.
        .............";

    #[test]
    fn test_visible_occupied_seats_at_2() {
        let layout: SeatLayout = VIS_ROW_LAYOUT.parse().unwrap();
        assert_eq!(0, layout.visible_occupied_seats_at(1, 1, i32::MAX));
        assert_eq!(1, layout.visible_occupied_seats_at(1, 3, i32::MAX));
    }

    #[test]
    fn test_visible_occupied_seats_at_3() {
        let layout = SeatLayout::read_from_file("input/vexample3.txt")
            .unwrap();
        assert_eq!(0, layout.visible_occupied_seats_at(3, 3, i32::MAX));
    }
}
