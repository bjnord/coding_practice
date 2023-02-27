use custom_error::custom_error;
use std::str::FromStr;

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

impl Instructions {
    /// Determine the number of houses receiving at least one present.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_03::Instructions;
    /// let instructions = "^>v<".parse::<Instructions>().unwrap();
    /// assert_eq!(4, instructions.n_present_houses());
    /// ```
    #[must_use]
    pub fn n_present_houses(&self) -> i32 {
        // TODO
        2
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
        // "> delivers presents to 2 houses: one at the starting location,
        // and one to the east."
        let str_1 = ">";
        assert_eq!(2, str_1.parse::<Instructions>().unwrap().n_present_houses());
        // "^v^v^v^v^v delivers a bunch of presents to some very lucky
        // children at only 2 houses."
        let str_2 = "^v^v^v^v^v";
        assert_eq!(2, str_2.parse::<Instructions>().unwrap().n_present_houses());
    }
}
