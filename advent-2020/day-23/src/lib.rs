use std::convert::TryFrom;
use std::fmt;
use std::str::FromStr;
use std::string::ToString;
use std::time::Instant;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

// we store two values for "current position"
// - `Circle.disp_pos` is shown to the user as part of `Display` "(3)"
//   - it's incremented each `do_moves()` loop -- always moves forward 1
// - `Circle.pos` is *not* shown to the user; it's *absolute*
//   - it's used as a direct index: `Circle.cups[pos]` -> "current cup"
//   - it will shift in both directions as cups are taken/put back
#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Circle {
    cups: Vec<u32>,
    len: usize,
    pos: usize,
    disp_pos: usize,
}

impl FromStr for Circle {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let cups: Vec<u32> = input
            .chars()
            .map(Circle::cup_from)
            .collect::<Result<Vec<u32>>>()?;
        let len = cups.len();
        Ok(Self { cups, len, pos: 0, disp_pos: 0 })
    }
}

impl fmt::Display for Circle {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let rot = Circle::pos_sub_wrap(self.pos, self.disp_pos, self.len);
        let s: String = self.cups_string(&self.cups[rot..], 0);
        let s1: String = self.cups_string(&self.cups[..rot], self.len - rot);
        write!(f, "{}{}", s, s1)
    }
}

impl Circle {
    /// Expand the circle to size `new_len`, filling in sequential numbers
    /// clockwise.
    pub fn expand_to(&mut self, new_len: usize) {
        let mut new_cups: Vec<u32> = Vec::with_capacity(new_len);
        new_cups.extend(&self.cups);
        new_cups.extend(&(self.len+1..=new_len).map(|i| u32::try_from(i).unwrap()).collect::<Vec<u32>>());
        self.cups = new_cups;
        self.len = new_len;
    }

    /// Return the three cups clockwise to the right of the "1" cup.
    pub fn pick_up_after_1(&mut self) -> Vec<u32> {
        let cup_pos = self.find_cup(1);
        self.pos = cup_pos.unwrap();
        self.pick_up()
    }

    #[must_use]
    fn cups_string(&self, cups: &[u32], rot: usize) -> String {
        cups
            .iter()
            .enumerate()
            .map(|(i, cup)| if i + rot == self.disp_pos {
                format!("({})", cup)
             } else {
                format!(" {} ", cup)
             })
             .collect::<Vec<String>>()
             .join("")
    }

    fn rotate_left(&mut self, n: usize) {
        self.cups.rotate_left(n);
        self.pos = Circle::pos_sub_wrap(self.pos, n, self.len);
    }

    /// Do `count` move rounds.
    pub fn do_moves(&mut self, count: usize, output: bool) {
        if output && self.len > 9 {
            panic!("output only works for part 1");
        }
        // We do the `if output` checks to minimize what this loop has to do
        // in the non-debugging case.
        //
        // DEBUG PERFORMANCE
        let start = Instant::now();
        let mut squawk: usize = 0x10;
        for move_n in 1..=count {
            let start_cups: Option<String> = if output { Some(format!("{}", self)) } else { None };
            let picked = self.pick_up();
            let picked_cups: Option<String> = if output {
                Some(picked
                    .iter()
                    .map(ToString::to_string)
                    .collect::<Vec<String>>()
                    .join(", ")
                )
            } else {
                None
            };
            let dest_cup = self.put_down(picked);
            if output {
                println!("-- move {} --", move_n);
                println!("cups: {}", start_cups.unwrap());
                println!("pick up: {}", picked_cups.unwrap());
                println!("destination: {}", dest_cup);
                println!();
            }
            self.pos = Circle::pos_add_wrap(self.pos, 1, self.len);
            self.disp_pos = Circle::pos_add_wrap(self.disp_pos, 1, self.len);
            //
            // DEBUG PERFORMANCE
            if move_n == squawk {
                let move_time = start.elapsed();
                eprintln!("{}/{} moves in {:?}", move_n, count, move_time);
                squawk *= 2;
            }
        }
    }

    // Calculate adding `+n` to `pos`, wrapping on modulus `len`.
    fn pos_add_wrap(pos: usize, n: usize, len: usize) -> usize {
        // FIXME PERFORMANCE use compare/add not rem_euclid()
        (pos + n).rem_euclid(len)
    }

    // Calculate subtracting `-n` from `pos`, wrapping on modulus `len`.
    fn pos_sub_wrap(pos: usize, n: usize, len: usize) -> usize {
        // FIXME PERFORMANCE use compare/subtract not rem_euclid()
        ((pos + len) - n).rem_euclid(len)
    }

    /// Pick up three cups clockwise from current position. Return the cups
    /// picked up.
    pub fn pick_up(&mut self) -> Vec<u32> {
        // how many cups are to the right of the current (absolute) pos?
        let to_right = self.len - self.pos;
        if to_right <= 3 {
            // rotate just enough to put the three at the end
            self.rotate_left(4 - to_right);
        }
        // now the three cups to be picked up are to the right of self.pos,
        // so self.pos will not need to be adjusted
        self.cups.splice(self.pos+1..self.pos+4, vec![]).collect()
    }

    /// Return destination cup from current position.
    #[must_use]
    pub fn destination(&self) -> u32 {
        self.cups[self.find_dest_pos()]
    }

    // Return position of "destination" cup (which is found according to the
    // game rules).
    #[must_use]
    fn find_dest_pos(&self) -> usize {
        let cur_cup = self.cups[self.pos];
        let mut dest_cup = cur_cup;
        // FIXME PERFORMANCE check picked cups first; then won't have to loop
        loop {
            dest_cup = Circle::cup_sub_wrap(dest_cup, 1, self.len);
            if let Some(dest_pos) = self.find_cup(dest_cup) {
                return dest_pos;
            }
        }
    }

    // Calculate subtracting `-n` from `cup`, wrapping on modulus `len`.
    fn cup_sub_wrap(cup: u32, n: u32, len: usize) -> u32 {
        let len8 = u32::try_from(len).unwrap();
        // FIXME PERFORMANCE use compare/subtract not rem_euclid()
        let c1 = ((cup + len8) - n).rem_euclid(len8);
        if c1 == 0 { len8 } else { c1 }
    }

    // Return position of provided `cup`.
    #[must_use]
    fn find_cup(&self, cup: u32) -> Option<usize> {
        self.cups.iter().position(|c| *c == cup)
    }

    /// Put down `cups` clockwise to the right of the "destination" cup
    /// (which is found according to the game rules). Returns the
    /// "destination" cup.
    #[allow(clippy::range_plus_one)]
    pub fn put_down(&mut self, cups: Vec<u32>) -> u32 {
        let dest_pos = self.find_dest_pos();
        let dest_cup = self.cups[dest_pos];
        self.cups.splice(dest_pos+1..dest_pos+1, cups);
        // if the three cups were inserted before self.pos, adjust it
        if dest_pos <= self.pos {
            self.pos += 3;
        }
        dest_cup
    }

    /// Return circle state string: Cups clockwise from cup 1 and excluding
    /// cup 1.
    #[must_use]
    pub fn state(&self) -> String {
        if self.len > 9 {
            panic!("state() only works for part 1");
        }
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

    // Convert cup character into cup number.
    fn cup_from(ch: char) -> Result<u32> {
        let cup: u32 = ch.to_digit(10).ok_or("not a digit")?;
        Ok(u32::try_from(cup).unwrap())
    }

    // Convert cup number into cup character.
    #[allow(clippy::trivially_copy_pass_by_ref)]
    fn cup_char(cup: &u32) -> char {
        ((*cup as u8) + b'0') as char
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE1: &'static str = "389125467";

    #[test]
    fn test_from_input() {
        let circle: Circle = EXAMPLE1.parse().unwrap();
        assert_eq!(9, circle.len);
        assert_eq!(0, circle.pos);
        assert_eq!(0, circle.disp_pos);
        assert_eq!(vec![3, 8, 9, 1, 2, 5, 4, 6, 7], circle.cups);
    }

    #[test]
    fn test_formatting() {
        let circle: Circle = EXAMPLE1.parse().unwrap();
        let cups = format!("{}", circle);
        assert_eq!("(3) 8  9  1  2  5  4  6  7 ", cups);
        assert_eq!("25467389", circle.state());
    }

    #[test]
    fn test_pick_up() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        assert_eq!(vec![8, 9, 1], circle.pick_up());
        assert_eq!(vec![3, 2, 5, 4, 6, 7], circle.cups);
        assert_eq!(0, circle.pos);
        assert_eq!(0, circle.disp_pos);
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

    // cups: (3) 8  9  1  2  5  4  6  7 
    // pick up: 8, 9, 1
    // left in circle: (3) 2  5  4  6  7
    //
    #[test]
    fn test_find_dest_pos() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.pick_up();
        assert_eq!(1, circle.find_dest_pos());  // cup (3) -> dest cup 2
    }

    // cups:  3  8  9  1  2  5  4  6 (7)
    // pick up: 3, 8, 9
    // left in circle:  1  2  5  4  6 (7)
    //
    #[test]
    fn test_find_dest_pos_wrap_pos() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.pos = 8;
        circle.pick_up();
        assert_eq!(4, circle.find_dest_pos());  // cup (7) -> dest cup 6
    }

    #[test]
    fn test_find_dest_pos_wrap_cup() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_moves(1, true);
        assert_eq!(" 3 (2) 8  9  1  5  4  6  7 ".to_string(), format!("{}", circle));
        let picked = circle.pick_up();
        assert_eq!(5, circle.find_dest_pos());  // cup (2) -> dest cup 7
    }

    #[test]
    fn test_put_down() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        let picked = circle.pick_up();
        assert_eq!(2, circle.destination());
        circle.put_down(picked);
        assert_eq!(vec![3, 2, 8, 9, 1, 5, 4, 6, 7], circle.cups);
    }

    #[test]
    fn test_do_moves() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_moves(2, true);
        assert_eq!(" 3  2 (5) 4  6  7  8  9  1 ".to_string(), format!("{}", circle));
    }

    #[test]
    fn test_do_moves_rotate() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_moves(3, true);
        assert_eq!(" 7  2  5 (8) 9  1  3  4  6 ".to_string(), format!("{}", circle));
    }

    #[test]
    fn test_do_moves_put_down_at_end() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_moves(6, true);
        assert_eq!(" 7  2  5  8  4  1 (9) 3  6 ".to_string(), format!("{}", circle));
    }

    #[test]
    fn test_do_moves_rotate_extra() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_moves(7, true);
        assert_eq!(" 8  3  6  7  4  1  9 (2) 5 ".to_string(), format!("{}", circle));
    }

    #[test]
    fn test_do_moves_final() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.do_moves(10, true);
        assert_eq!(" 5 (8) 3  7  4  1  9  2  6 ".to_string(), format!("{}", circle));
        assert_eq!("92658374", circle.state());
    }

    #[test]
    fn test_cup_from() {
        assert_eq!(7_u32, Circle::cup_from('7').unwrap());
    }

    #[test]
    fn test_cup_from_non_digit() {
        match Circle::cup_from('-') {
            Err(e) => assert!(e.to_string().contains("not a digit")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_rotate_left_1() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        let old_cups = format!("{}", circle);
        let old_state = circle.state();
        circle.rotate_left(1);
        assert_eq!(old_cups, format!("{}", circle));
        assert_eq!(old_state, circle.state());
    }

    #[test]
    fn test_rotate_left_8() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        let old_cups = format!("{}", circle);
        let old_state = circle.state();
        circle.rotate_left(2);
        assert_eq!(old_cups, format!("{}", circle));
        assert_eq!(old_state, circle.state());
    }

    #[test]
    fn test_pos_add_wrap() {
        assert_eq!(3_usize, Circle::pos_add_wrap(2, 1, 5));
        assert_eq!(4_usize, Circle::pos_add_wrap(3, 1, 5));
        assert_eq!(4_usize, Circle::pos_add_wrap(0, 4, 5));
        assert_eq!(0_usize, Circle::pos_add_wrap(4, 1, 5));
        assert_eq!(0_usize, Circle::pos_add_wrap(0, 5, 5));
        assert_eq!(1_usize, Circle::pos_add_wrap(5, 1, 5));
    }

    #[test]
    fn test_pos_sub_wrap() {
        assert_eq!(1_usize, Circle::pos_sub_wrap(2, 1, 5));
        assert_eq!(0_usize, Circle::pos_sub_wrap(1, 1, 5));
        assert_eq!(4_usize, Circle::pos_sub_wrap(0, 1, 5));
        assert_eq!(4_usize, Circle::pos_sub_wrap(5, 1, 5));
        assert_eq!(2_usize, Circle::pos_sub_wrap(2, 5, 5));
    }

    #[test]
    fn test_cup_sub_wrap() {
        assert_eq!(1_u32, Circle::cup_sub_wrap(2, 1, 9));
        assert_eq!(9_u32, Circle::cup_sub_wrap(1, 1, 9));
        assert_eq!(8_u32, Circle::cup_sub_wrap(1, 2, 9));
        assert_eq!(8_u32, Circle::cup_sub_wrap(9, 1, 9));
        assert_eq!(3_u32, Circle::cup_sub_wrap(3, 9, 9));
    }

    #[test]
    fn test_expand_to() {
        let mut circle: Circle = EXAMPLE1.parse().unwrap();
        circle.expand_to(30);
        assert_eq!(30, circle.len);
        assert_eq!(0, circle.pos);
        assert_eq!(0, circle.disp_pos);
        assert_eq!(vec![
            3, 8, 9, 1, 2, 5, 4, 6, 7, 10,
            11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
            21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
        ], circle.cups);
    }

//  [this isn't practical as a test (which = debug mode)]
//
//    #[test]
//    fn test_part_2_example() {
//        let mut circle: Circle = EXAMPLE1.parse().unwrap();
//        let size = 1_000_000_usize;
//        let moves = 10_000_000_usize;
//        circle.expand_to(size);
//        circle.do_moves(moves, false);
//        let picked: Vec<u32> = circle.pick_up_after_1();
//        assert_eq!(934001, picked[0]);
//        assert_eq!(159792, picked[1]);
//        let answer: u64 = (picked[0] as u64) * (picked[1] as u64);
//        assert_eq!(149245887792, answer);
//    }
}
