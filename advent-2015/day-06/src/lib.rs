use custom_error::custom_error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, Hash, PartialEq)]
pub struct Position {
    pub y: u32,
    pub x: u32,
}

custom_error! {pub PositionError
    InvalidString{s: String} = "invalid string '{s}'",
    InvalidCoordinate{source: std::num::ParseIntError} = "non-integer coordinate",
}

impl FromStr for Position {
    type Err = PositionError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let coordinates: Vec<u32> = s
            .split(',')
            .map(|dim| dim.parse::<u32>().map_err(Into::into))
            .collect::<Result<Vec<u32>, Self::Err>>()?;
        if coordinates.len() == 2 {
            Ok(Self {
                x: coordinates[0],
                y: coordinates[1],
            })
        } else {
            Err(PositionError::InvalidString { s: String::from(s) })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_position_parse() {
        let exp = Position { y: 500, x: 499 };
        assert_eq!(exp, "499,500".parse().unwrap());
    }

    #[test]
    fn test_position_parse_invalid_string() {
        let e = "499,500,501".parse::<Position>().unwrap_err();
        assert_eq!("invalid string '499,500,501'", e.to_string());
    }

    #[test]
    fn test_position_parse_invalid_coordinate() {
        let e = "499xSOO".parse::<Position>().unwrap_err();
        assert_eq!("non-integer coordinate", e.to_string());
    }
}
