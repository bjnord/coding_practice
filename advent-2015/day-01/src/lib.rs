use custom_error::custom_error;

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
}
