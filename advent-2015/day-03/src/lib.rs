#[macro_use]
extern crate maplit;

use custom_error::custom_error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Position {
    pub y: i32,
    pub x: i32,
}

impl Position {
    /// Add two positions (vectors), returning the new position (sum).
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::Position;
    /// let p0 = Position{y: -2, x: 3};
    /// let dp = Position{y: 1, x: -1};
    /// let p1 = p0.add(dp);
    /// assert_eq!(p1.y, -1);
    /// assert_eq!(p1.x, 2);
    /// ```
    #[must_use]
    pub fn add(&self, p: Position) -> Position {
        Position {
            y: self.y + p.y,
            x: self.x + p.x,
        }
    }

    /// Create string key from position.
    ///
    /// This is _e.g._ suitable to use with `HashMap`.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::Position;
    /// let p = Position{y: -2, x: 3};
    /// assert_eq!(String::from("-2,3"), p.key());
    /// ```
    #[must_use]
    pub fn key(&self) -> String {
        format!("{},{}", self.y, self.x)
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum Direction {
    North,
    South,
    East,
    West,
}

custom_error! {pub DirectionError
    InvalidDirChar{dir: char} = "invalid direction character '{dir}'",
}

impl Direction {
    /// Construct direction from input character.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::Direction;
    /// assert_eq!(Direction::West, Direction::from_char('<').unwrap());
    /// assert_eq!(Direction::North, Direction::from_char('^').unwrap());
    /// ```
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input character is not a valid direction.
    pub fn from_char(dir: char) -> Result<Self, DirectionError> {
        // "north (^), south (v), east (>), or west (<)"
        match dir {
            '^' => Ok(Direction::North),
            'v' => Ok(Direction::South),
            '>' => Ok(Direction::East),
            '<' => Ok(Direction::West),
            _ => Err(DirectionError::InvalidDirChar { dir }),
        }
    }

    /// Return corresponding position delta for this direction.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::{Direction, Position};
    /// let dir_n = Direction::North;
    /// assert_eq!(Position{y: -1, x: 0}, dir_n.delta_pos());
    /// let dir_e = Direction::East;
    /// assert_eq!(Position{y: 0, x: 1}, dir_e.delta_pos());
    /// ```
    #[must_use]
    pub fn delta_pos(&self) -> Position {
        match self {
            Direction::North => Position { y: -1, x: 0 },
            Direction::South => Position { y: 1, x: 0 },
            Direction::East => Position { y: 0, x: 1 },
            Direction::West => Position { y: 0, x: -1 },
        }
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Instructions {
    directions: Vec<Direction>,
}

impl FromStr for Instructions {
    type Err = DirectionError;

    fn from_str(s: &str) -> Result<Self, DirectionError> {
        let directions: Vec<Direction> = s
            .chars()
            .map(Direction::from_char)
            .collect::<Result<Vec<Direction>, DirectionError>>()?;
        Ok(Self { directions })
    }
}

// TODO DRY up `.fold()` guts with `Grid` struct
impl Instructions {
    /// Determine the number of houses receiving at least one present after all instructions are
    /// followed.
    ///
    /// In this version, Santa does all the deliveries.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::Instructions;
    /// let instructions = "^>v<".parse::<Instructions>().unwrap();
    /// assert_eq!(4, instructions.n_present_houses());
    /// ```
    #[must_use]
    pub fn n_present_houses(&self) -> usize {
        let mut pos = Position { y: 0, x: 0 };
        let grid = self
            .directions
            .iter()
            .fold(hashmap! {pos.key() => 1}, |mut acc, dir| {
                pos = pos.add(dir.delta_pos());
                *acc.entry(pos.key()).or_insert(0) += 1;
                acc
            });
        grid.len()
    }

    /// Determine the number of houses receiving at least one present after all instructions are
    /// followed.
    ///
    /// In this version, Santa and Robo-Santa alternate deliveries.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::Instructions;
    /// let instructions = "^>v<".parse::<Instructions>().unwrap();
    /// assert_eq!(3, instructions.n_present_houses_robo());
    /// ```
    #[must_use]
    pub fn n_present_houses_robo(&self) -> usize {
        let mut pos = Position { y: 0, x: 0 };
        let mut grid =
            self.directions
                .iter()
                .step_by(2)
                .fold(hashmap! {pos.key() => 2}, |mut acc, dir| {
                    pos = pos.add(dir.delta_pos());
                    *acc.entry(pos.key()).or_insert(0) += 1;
                    acc
                });
        pos = Position { y: 0, x: 0 };
        grid = self
            .directions
            .iter()
            .skip(1)
            .step_by(2)
            .fold(grid, |mut acc, dir| {
                pos = pos.add(dir.delta_pos());
                *acc.entry(pos.key()).or_insert(0) += 1;
                acc
            });
        grid.len()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_direction_from_char() {
        assert_eq!(Direction::East, Direction::from_char('>').unwrap());
        assert_eq!(Direction::South, Direction::from_char('v').unwrap());
    }

    #[test]
    fn test_direction_from_char_invalid() {
        let e = Direction::from_char('[').unwrap_err();
        assert_eq!("invalid direction character '['", e.to_string());
    }

    #[test]
    fn test_direction_delta_pos() {
        let dir_s = Direction::South;
        assert_eq!(Position { y: 1, x: 0 }, dir_s.delta_pos());
        let dir_w = Direction::West;
        assert_eq!(Position { y: 0, x: -1 }, dir_w.delta_pos());
    }

    #[test]
    fn test_instructions_parse() {
        let str = "^>v<";
        let exp_directions: Vec<Direction> = vec![
            Direction::North,
            Direction::East,
            Direction::South,
            Direction::West,
        ];
        assert_eq!(
            Instructions {
                directions: exp_directions
            },
            str.parse().unwrap()
        );
    }

    #[test]
    fn test_instructions_parse_invalid() {
        let e = "^(v)".parse::<Instructions>().unwrap_err();
        assert_eq!("invalid direction character '('", e.to_string());
    }

    #[test]
    fn test_instructions_n_present_houses() {
        // "> delivers presents to 2 houses: one at the starting location, and one to the east."
        let str_1 = ">";
        assert_eq!(2, str_1.parse::<Instructions>().unwrap().n_present_houses());
        // "^v^v^v^v^v delivers a bunch of presents to some very lucky children at only 2 houses."
        let str_2 = "^v^v^v^v^v";
        assert_eq!(2, str_2.parse::<Instructions>().unwrap().n_present_houses());
    }

    #[test]
    fn test_instructions_n_present_houses_robo() {
        // "^v delivers presents to 3 houses, because Santa goes north, and then Robo-Santa goes
        // south."
        let str_1 = "^v";
        assert_eq!(
            3,
            str_1
                .parse::<Instructions>()
                .unwrap()
                .n_present_houses_robo()
        );
        // "^v^v^v^v^v now delivers presents to 11 houses, with Santa going one direction and
        // Robo-Santa going the other."
        let str_2 = "^v^v^v^v^v";
        assert_eq!(
            11,
            str_2
                .parse::<Instructions>()
                .unwrap()
                .n_present_houses_robo()
        );
    }
}
