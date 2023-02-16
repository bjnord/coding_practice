use custom_error::custom_error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum Direction {
    Up,
    Down,
}

custom_error!{#[derive(PartialEq)]
    pub DirectionError
    InvalidDirChar{dir: char} = "invalid direction character '{dir}'",
}

impl Direction {
    /// Construct direction from input character.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_01::Direction;
    /// assert_eq!(Direction::Up, Direction::from_char('(').unwrap());
    /// assert_eq!(Direction::Down, Direction::from_char(')').unwrap());
    /// ```
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input character is not a valid direction.
    #[must_use]
    pub fn from_char(dir: char) -> Result<Self, DirectionError> {
        match dir {
            '(' => Ok(Direction::Up),
            ')' => Ok(Direction::Down),
            _ => Err(DirectionError::InvalidDirChar { dir })
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
    /// Return the floor reached after following instructions.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_01::Instructions;
    /// let instructions = "(()".parse::<Instructions>().unwrap();
    /// assert_eq!(1, instructions.floor());
    /// ```
    #[must_use]
    pub fn floor(&self) -> i32 {
        self.directions.iter()
            .map(Self::floor_delta)
            .sum()
    }

    fn floor_delta(d: &Direction) -> i32 {
        match d {
            Direction::Up => 1,
            Direction::Down => -1,
        }
    }

    /// Return the first step that enters the basement, or `0` if
    /// no step does.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_01::Instructions;
    /// let mut instructions = "()())".parse::<Instructions>().unwrap();
    /// assert_eq!(5, instructions.basement());
    /// instructions = "(()".parse::<Instructions>().unwrap();
    /// assert_eq!(0, instructions.basement());
    /// ```
    #[must_use]
    pub fn basement(&self) -> usize {
        let mut f: i32 = 0;
        for (i, df) in self.directions.iter().map(Self::floor_delta).enumerate() {
            f += df;
            if f < 0 {
                return i + 1;
            }
        }
        0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_direction_from_char() {
        assert_eq!(Direction::Up, Direction::from_char('(').unwrap());
        assert_eq!(Direction::Down, Direction::from_char(')').unwrap());
    }

    #[test]
    fn test_direction_from_char_invalid() {
        match Direction::from_char('[') {
            Err(e) => {
                assert_eq!(DirectionError::InvalidDirChar { dir: '[' }, e);
                assert_eq!("invalid direction character '['", e.to_string());
            },
            Ok(_) => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_instructions_from_str() {
        let str = "(()())";
        let exp_directions: Vec<Direction> = vec![
            Direction::Up, Direction::Up,
            Direction::Down, Direction::Up,
            Direction::Down, Direction::Down,
        ];
        assert_eq!(Instructions { directions: exp_directions }, Instructions::from_str(str).unwrap());
    }

    #[test]
    fn test_instructions_from_str_invalid() {
        match Instructions::from_str("((>())") {
            Err(e) => {
                assert_eq!(DirectionError::InvalidDirChar { dir: '>' }, e);
                assert_eq!("invalid direction character '>'", e.to_string());
            },
            Ok(_) => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_instructions_floor_3() {
        let str_1 = "(((";
        assert_eq!(3, Instructions::from_str(str_1).unwrap().floor());
        let str_2 = "(()(()(";
        assert_eq!(3, Instructions::from_str(str_2).unwrap().floor());
        let str_3 = "))(((((";
        assert_eq!(3, Instructions::from_str(str_3).unwrap().floor());
    }

    #[test]
    fn test_instructions_floor_m1() {
        let str_1 = "())";
        assert_eq!(-1, Instructions::from_str(str_1).unwrap().floor());
        let str_2 = "))(";
        assert_eq!(-1, Instructions::from_str(str_2).unwrap().floor());
    }

    #[test]
    fn test_instructions_floor_m3() {
        let str_1 = ")))";
        assert_eq!(-3, Instructions::from_str(str_1).unwrap().floor());
        let str_2 = ")())())";
        assert_eq!(-3, Instructions::from_str(str_2).unwrap().floor());
    }

    #[test]
    fn test_instructions_basement_1() {
        let s = ")";
        assert_eq!(1, Instructions::from_str(s).unwrap().basement());
    }
}
