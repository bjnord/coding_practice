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
        let s: String = self.cups
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

impl Circle {
    /// Pick up three cups clockwise from current position.
    pub fn pick_up(&mut self) -> Vec<u8> {
        if self.len - self.pos > 3 {
            return self.cups.splice(self.pos+1..self.pos+4, vec![]).collect();
        }
        if self.len - self.pos == 1 {
            self.pos -= 3;
            return self.cups.splice(..3, vec![]).collect();
        }
        let begin_count = 3 - (self.len - self.pos - 1);
        let mut u: Vec<u8> = self.cups.splice(self.pos+1.., vec![]).collect();
        let v: Vec<u8> = self.cups.splice(..begin_count, vec![]).collect();
        u.extend(v);
        self.pos -= begin_count;
        u
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE1: &'static str = "389125467";

    #[test]
    fn test_from_input() {
        let circle: Circle = EXAMPLE1.parse().unwrap();
        assert_eq!(0, circle.pos);
        assert_eq!(9, circle.len);
        assert_eq!(vec![3, 8, 9, 1, 2, 5, 4, 6, 7], circle.cups);
    }

    #[test]
    fn test_pick_up() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        assert_eq!(vec![8, 9, 1], circle.pick_up());
        assert_eq!(vec![3, 2, 5, 4, 6, 7], circle.cups);
        assert_eq!(0, circle.pos);
    }

    #[test]
    fn test_pick_up_wrap_all_at_front() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.pos = 8;
        assert_eq!(vec![3, 8, 9], circle.pick_up());
        assert_eq!(vec![1, 2, 5, 4, 6, 7], circle.cups);
        assert_eq!(5, circle.pos);
    }

    #[test]
    fn test_pick_up_wrap_split() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.pos = 7;
        assert_eq!(vec![7, 3, 8], circle.pick_up());
        assert_eq!(vec![9, 1, 2, 5, 4, 6], circle.cups);
        assert_eq!(5, circle.pos);
    }
}
