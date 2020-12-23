use std::convert::TryFrom;
use std::fmt;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Circle {
    pos: usize,
    len: usize,
    cups: Vec<u8>,
}

impl FromStr for Circle {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let cups: Vec<u8> = input
            .chars()
            // FIXME propagate error
            .map(|c| u8::try_from(c.to_digit(10).unwrap()).unwrap())
            .collect();
        let len = cups.len();
        Ok(Self { cups, pos: 0, len })
    }
}

impl fmt::Display for Circle {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        s += self.cups
            .iter()
            .enumerate()
            .map(|(i, cup)| if i == self.pos {
                format!("({})", cup)
             } else {
                format!("{} ", cup)
             })
             .collect::<Vec<String>>()
             .join(" ")
             .replace(" (", "(");
        write!(f, "{}", s)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE1: &'static str = "389125467";

    #[test]
    fn test_from_input() {
        let circle: Circle = EXAMPLE1.parse().unwrap();
        eprintln!("circle = [{}]", circle);
        assert_eq!(0, circle.pos);
        assert_eq!(9, circle.len);
        assert_eq!(vec![3, 8, 9, 1, 2, 5, 4, 6, 7], circle.cups);
    }
}
