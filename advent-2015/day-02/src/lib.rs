use custom_error::custom_error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Package {
    pub length: u32,
    pub width: u32,
    pub height: u32,
}

custom_error! {#[derive(PartialEq)]
    pub PackageError
    InvalidString{s: String} = "invalid string '{s}'",
    InvalidDimension{dim: String, value: String} = "invalid {dim} '{value}'",
}

impl FromStr for Package {
    type Err = PackageError;

    fn from_str(s: &str) -> Result<Self, PackageError> {
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
            Err(PackageError::InvalidString { s: String::from(s) })
        }
    }
}

impl Package {
    /// Calculate the square feet of wrapping paper required for this package.
    ///
    /// Examples
    /// ```
    /// # use day_02::Package;
    /// let package: Package = "5x6x7".parse().unwrap();
    /// assert_eq!(244, package.paper());
    /// ```
    #[must_use]
    pub fn paper(&self) -> u32 {
        let min = self.min_dimensions();
        2 * self.length * self.width
            + 2 * self.width * self.height
            + 2 * self.height * self.length
            + min.0 * min.1
    }

    // Calculate the dimensions of the smallest face of this package.
    fn min_dimensions(&self) -> (u32, u32) {
        #[allow(clippy::collapsible_else_if)]
        if self.length < self.width {
            if self.width < self.height {
                (self.length, self.width)
            } else {
                (self.length, self.height)
            }
        } else if self.width < self.height {
            if self.height < self.length {
                (self.width, self.height)
            } else {
                (self.width, self.length)
            }
        } else {
            if self.width < self.length {
                (self.height, self.width)
            } else {
                (self.height, self.length)
            }
        }
    }

    /// Calculate the feet of ribbon required for this package.
    ///
    /// Examples
    /// ```
    /// # use day_02::Package;
    /// let package: Package = "5x6x7".parse().unwrap();
    /// assert_eq!(232, package.ribbon());
    /// ```
    #[must_use]
    pub fn ribbon(&self) -> u32 {
        let min = self.min_dimensions();
        2 * min.0 + 2 * min.1 + self.cubic()
    }

    // Calculate the cubic feet of this package.
    fn cubic(&self) -> u32 {
        self.length * self.width * self.height
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wrapping_parse() {
        let exp = Package {
            length: 5,
            width: 6,
            height: 7,
        };
        assert_eq!(exp, "5x6x7".parse().unwrap());
    }

    #[test]
    fn test_wrapping_parse_invalid() {
        match "5x6x7x8".parse::<Package>() {
            Err(e) => {
                assert_eq!(
                    PackageError::InvalidString {
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
    fn test_wrapping_min_dimensions() {
        let examples = vec!["5x6x7", "5x7x6", "6x5x7", "6x7x5", "7x5x6", "7x6x5"];
        for example in examples {
            let p: Package = example.parse().unwrap();
            let min = p.min_dimensions();
            assert_eq!(30, min.0 * min.1);
        }
    }

    // "A present with dimensions 2x3x4 requires 2*6 + 2*12 + 2*8 = 52 square feet of wrapping
    // paper plus 6 square feet of slack, for a total of 58 square feet."
    #[test]
    fn test_wrapping_paper_ex1() {
        let p: Package = "2x3x4".parse().unwrap();
        assert_eq!(58, p.paper());
    }

    // "A present with dimensions 1x1x10 requires 2*1 + 2*10 + 2*10 = 42 square feet of wrapping
    // paper plus 1 square foot of slack, for a total of 43 square feet."
    #[test]
    fn test_wrapping_paper_ex2() {
        let p: Package = "1x1x10".parse().unwrap();
        assert_eq!(43, p.paper());
    }

    #[test]
    fn test_wrapping_cubic() {
        let p: Package = "6x7x5".parse().unwrap();
        assert_eq!(210, p.cubic());
    }

    // "A present with dimensions 2x3x4 requires 2+2+3+3 = 10 feet of ribbon to wrap the present
    // plus 2*3*4 = 24 feet of ribbon for the bow, for a total of 34 feet."
    #[test]
    fn test_wrapping_ribbon_ex1() {
        let p: Package = "2x3x4".parse().unwrap();
        assert_eq!(34, p.ribbon());
    }

    // "A present with dimensions 1x1x10 requires 1+1+1+1 = 4 feet of ribbon to wrap the present
    // plus 1*1*10 = 10 feet of ribbon for the bow, for a total of 14 feet."
    #[test]
    fn test_wrapping_ribbon_ex2() {
        let p: Package = "1x1x10".parse().unwrap();
        assert_eq!(14, p.ribbon());
    }
}
