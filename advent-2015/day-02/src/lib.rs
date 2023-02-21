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

impl Wrapping {
    #[must_use]
    pub fn area(&self) -> u32 {
        2 * self.length * self.width
            + 2 * self.width * self.height
            + 2 * self.height * self.length
            + self.extra()
    }

    fn extra(&self) -> u32 {
        #[allow(clippy::collapsible_else_if)]
        if self.length < self.width {
            if self.width < self.height {
                self.length * self.width
            } else {
                self.length * self.height
            }
        } else if self.width < self.height {
            if self.height < self.length {
                self.width * self.height
            } else {
                self.width * self.length
            }
        } else {
            if self.width < self.length {
                self.height * self.width
            } else {
                self.height * self.length
            }
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

    #[test]
    fn test_wrapping_extra() {
        let examples = vec!["5x6x7", "5x7x6", "6x5x7", "6x7x5", "7x5x6", "7x6x5"];
        for example in examples {
            let w = Wrapping::from_str(example).unwrap();
            assert_eq!(30, w.extra());
        }
    }

    // "A present with dimensions 2x3x4 requires 2*6 + 2*12 + 2*8 = 52 square feet of wrapping
    // paper plus 6 square feet of slack, for a total of 58 square feet."
    #[test]
    fn test_wrapping_area_ex1() {
        let w = Wrapping::from_str("2x3x4").unwrap();
        assert_eq!(58, w.area());
    }

    // "A present with dimensions 1x1x10 requires 2*1 + 2*10 + 2*10 = 42 square feet of wrapping
    // paper plus 1 square foot of slack, for a total of 43 square feet."
    #[test]
    fn test_wrapping_area_ex2() {
        let w = Wrapping::from_str("1x1x10").unwrap();
        assert_eq!(43, w.area());
    }
}
