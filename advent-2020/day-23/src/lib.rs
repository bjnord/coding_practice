use std::convert::TryFrom;
use std::fmt;
use std::str::FromStr;
use std::string::ToString;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Circle {
    pos: usize,
    len: usize,
    cups: Vec<u8>,
    move_n: usize,
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
        Ok(Self { cups, pos: 0, len, move_n: 0 })
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
    /// Do one move round.
    pub fn do_move(&mut self, output: bool) {
        self.move_n += 1;
        if output {
            println!("-- move {} --", self.move_n);
            println!("cups: {}", self);
        }
        let old_pos = self.pos;
        let picked = self.pick_up();
        let pos_shift = old_pos - self.pos;
        let dest_pos = self.find_dest(self.pos);
        if output {
            let pick_up: String = picked
                .iter()
                .map(ToString::to_string)
                .collect::<Vec<String>>()
                .join(", ");
            println!("pick up: {}", pick_up);
            println!("destination: {}", self.dest_cup());
            println!();
        }
        self.put_down(dest_pos, picked, pos_shift);
        let mut new_pos = Circle::pos_add_1(self.pos, self.len);
        for _ in 0..pos_shift {
            new_pos = Circle::pos_add_1(new_pos, self.len);
        }
        self.pos = new_pos;
    }

    fn pos_add_1(pos: usize, len: usize) -> usize {
        (pos + 1).rem_euclid(len)
    }

    /// Pick up three cups clockwise from current position. Return the cups
    /// picked up.
    pub fn pick_up(&mut self) -> Vec<u8> {
        // take all 3 from middle or end
        if self.len - self.pos > 3 {
            return self.cups.splice(self.pos+1..self.pos+4, vec![]).collect();
        }
        // take all 3 from beginning
        if self.len - self.pos == 1 {
            self.pos -= 3;
            return self.cups.splice(..3, vec![]).collect();
        }
        // split: take some from end, some from beginning
        let begin_count = 3 - (self.len - self.pos - 1);
        let mut u: Vec<u8> = self.cups.splice(self.pos+1.., vec![]).collect();
        let v: Vec<u8> = self.cups.splice(..begin_count, vec![]).collect();
        u.extend(v);
        self.pos -= begin_count;
        u
    }

    /// Return destination *cup* from current position.
    #[must_use]
    pub fn dest_cup(&self) -> u8 {
        self.cups[self.find_dest(self.pos)]
    }

    /// Return destination *position* from given (current) `pos`.
    #[must_use]
    pub fn find_dest(&self, pos: usize) -> usize {
        let cur_cup = self.cups[pos];
        let mut dest_cup = cur_cup;
        loop {
            dest_cup = Circle::cup_sub_1(dest_cup, self.len);
            if let Some(dest_pos) = self.cups.iter().position(|cup| *cup == dest_cup) {
                return dest_pos;
            }
        }
    }

    /// Put down `cups` clockwise from the given `pos`.
    #[allow(clippy::range_plus_one)]
    pub fn put_down(&mut self, pos: usize, cups: Vec<u8>, pos_shift: usize) {
        self.cups.splice(pos+1..pos+1, cups);
        if pos < self.pos {
            let rot: Vec<u8> = self.cups.splice(..3-pos_shift, vec![]).collect();
            self.cups.extend(rot);
        }
    }

    fn cup_sub_1(n: u8, len: usize) -> u8 {
        let len8 = u8::try_from(len).unwrap();
        let nm1 = ((n + len8) - 1).rem_euclid(len8);
        if nm1 == 0 { len8 } else { nm1 }
    }

    /// Return circle state string: Cups clockwise from cup 1 and excluding
    /// cup 1.
    #[must_use]
    pub fn state(&self) -> String {
        if let Some(pos1) = self.cups.iter().position(|cup| *cup == 1) {
            let back: String = self.cups[pos1+1..]
                .iter()
                .map(Circle::cup_char)
                .collect();
            let front: String = self.cups[..pos1]
                .iter()
                .map(Circle::cup_char)
                .collect();
            format!("{}{}", back, front)
        } else {
            panic!("couldn't find cup 1");
        }
    }

    #[allow(clippy::trivially_copy_pass_by_ref)]
    fn cup_char(cup: &u8) -> char {
        (cup + b'0') as char
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

    // pick up: 8, 9, 1
    // left in circle: (3) 2  5  4  6  7
    //
    #[test]
    fn test_find_dest() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.pick_up();
        assert_eq!(1, circle.find_dest(0));  // cup (3) -> dest cup 2
    }
    //
    #[test]
    fn test_find_dest_wrap_cup() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.pick_up();
        assert_eq!(5, circle.find_dest(1));  // cup (2) -> dest cup 7
    }

    #[test]
    fn test_do_find_dest_wrap_pos() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        for _ in 0..5 {
            circle.do_move(true);
        }
        assert_eq!(vec![9, 2, 5, 8, 4, 1, 3, 6, 7], circle.cups);
        assert_eq!(5, circle.pos);
        let picked = circle.pick_up();
        assert_eq!(vec![3, 6, 7], picked);
        assert_eq!(5, circle.pos);
        assert_eq!(0, circle.find_dest(5));  // cup (1) -> dest cup 9
    }

    #[test]
    fn test_put_down() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        let picked = circle.pick_up();
        assert_eq!(1, circle.find_dest(0));
        circle.put_down(1, picked, 0);
        assert_eq!(vec![3, 2, 8, 9, 1, 5, 4, 6, 7], circle.cups);
    }

    #[test]
    fn test_do_move() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_move(true);
        assert_eq!(vec![3, 2, 8, 9, 1, 5, 4, 6, 7], circle.cups);
        assert_eq!(1, circle.pos);
    }

    #[test]
    fn test_do_move_rotate() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        for _ in 0..3 {
            circle.do_move(true);
        }
        assert_eq!(vec![7, 2, 5, 8, 9, 1, 3, 4, 6], circle.cups);
        assert_eq!(3, circle.pos);
    }

    #[test]
    fn test_do_move_put_down_at_end() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        for _ in 0..6 {
            circle.do_move(true);
        }
        assert_eq!(vec![7, 2, 5, 8, 4, 1, 9, 3, 6], circle.cups);
        assert_eq!(6, circle.pos);
    }

    #[test]
    fn test_do_move_rotate_extra() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        for _ in 0..7 {
            circle.do_move(true);
        }
        // 8  3  6  7  4  1  9 (2) 5
        assert_eq!(vec![8, 3, 6, 7, 4, 1, 9, 2, 5], circle.cups);
        assert_eq!(7, circle.pos);
    }

    #[test]
    fn test_do_move_final() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        for _ in 0..10 {
            circle.do_move(true);
        }
        assert_eq!(vec![5, 8, 3, 7, 4, 1, 9, 2, 6], circle.cups);
        assert_eq!(1, circle.pos);
        assert_eq!("92658374", circle.state());
    }
}
