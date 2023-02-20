use custom_error::custom_error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Wrapping {
    length: u32,
    width: u32,
    height: u32,
}

custom_error! {#[derive(PartialEq)]
    pub WrappingError
    InvalidString{s: String} = "invalid string '{s}'",
    InvalidDimension{dim: String, value: String} = "invalid {dim} '{value}'",
}

impl FromStr for Wrapping {
    type Err = WrappingError;

    fn from_str(s: &str) -> Result<Self, WrappingError> {
        let dimensions: Vec<u32> = s
            .split('x')
            .map(|dim| dim.parse::<u32>().unwrap())
            .collect::<Vec<u32>>();
        if dimensions.len() == 3 {
            Ok(Self {
                length: dimensions[0],
                width: dimensions[1],
                height: dimensions[2],
            })
        } else {
            Err(WrappingError::InvalidString { s: String::from(s) })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wrapping_from_string() {
        let exp = Wrapping {
            length: 5,
            width: 6,
            height: 7,
        };
        assert_eq!(exp, Wrapping::from_str("5x6x7").unwrap());
    }

    #[test]
    fn test_wrapping_from_string_invalid() {
        match Wrapping::from_str("5x6x7x8") {
            Err(e) => {
                assert_eq!(
                    WrappingError::InvalidString {
                        s: String::from("5x6x7x8")
                    },
                    e
                );
                assert_eq!("invalid string '5x6x7x8'", e.to_string());
            }
            Ok(_) => panic!("test did not fail"),
        }
    }

    //TODO fn test_wrapping_with_invalid_dimension()
}
