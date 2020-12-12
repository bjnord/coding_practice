#[macro_use] extern crate scan_fmt;
use std::error;
use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Instruction> = result::Result<Instruction, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct InstructionError(String);

impl fmt::Display for InstructionError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Instruction error: {}", self.0)
    }
}

impl error::Error for InstructionError {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ActionValue {
    Compass(i32, i32),
    Left(i32),
    Right(i32),
    Forward(i32),
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Instruction {
    action: ActionValue,
}

#[derive(Debug)]
pub struct Ferry {
    instructions: Vec<Instruction>,
    y: i32,
    x: i32,
    dir: i32,
}

impl FromStr for Instruction {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let (action_char, value) = scan_fmt!(line, "{[NSEWLRF]}{d}", char, i32)?;
        let action = match action_char {
            'N' => ActionValue::Compass(270, value),
            'S' => ActionValue::Compass(90, value),
            'E' => ActionValue::Compass(0, value),
            'W' => ActionValue::Compass(180, value),
            'L' => ActionValue::Left(value),
            'R' => ActionValue::Right(value),
            'F' => ActionValue::Forward(value),
            _ => {
                let e = format!("invalid instruction '{}' in line [{}]", action_char, line);
                return Err(InstructionError(e).into());
            },
        };
        Ok(Self { action })
    }
}

impl Instruction {
    /// Return instruction action.
    #[must_use]
    pub fn action(&self) -> ActionValue {
        self.action
    }

    /// Return (y, x) deltas for the given compass `dir`. The first value
    /// `y` is the north(-1)/south(+1) delta, the second value `x` is the
    /// east(+1)/west(-1). The compass directions start with East=0 and go
    /// clockwise.
    ///
    /// Only 90-degree values (cardinal directions) are supported. `dir`
    /// may be negative or greater than 360; it is treated as modulo 360.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_12::Instruction;
    /// let (dy, dx) = Instruction::compass_deltas(90);
    /// assert_eq!((1, 0), (dy, dx));
    /// ```
    #[must_use]
    pub fn compass_deltas(dir: i32) -> (i32, i32) {
        match dir.rem_euclid(360) {
            0 => (0, 1),
            90 => (1, 0),
            180 => (0, -1),
            270 => (-1, 0),
            dir => panic!("unsupported direction {}", dir),
        }
    }

    /// Read instructions from `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<Vec<Instruction>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }
}

impl Ferry {
    /// Return ferry north(-)/south(+) position.
    #[must_use]
    pub fn ns(&self) -> i32 {
        self.y
    }

    /// Return ferry east(+)/west(-) position.
    #[must_use]
    pub fn ew(&self) -> i32 {
        self.x
    }

    /// Return ferry Manhattan distance.
    #[must_use]
    pub fn manhattan(&self) -> i32 {
        self.x.abs() + self.y.abs()
    }

    /// Construct by reading instructions from path.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<Ferry> {
        let instructions = Instruction::read_from_file(path)?;
        Ok(Self { instructions, y: 0, x: 0, dir: 0 })
    }

    /// Follow list of ferry instructions to move the boat.
    pub fn follow_instructions(&mut self) {
        let (y1, x1, dir1) = self.instructions
            .iter()
            .fold((self.y, self.x, self.dir), |(y, x, dir), &inst| {
                match inst.action() {
                    ActionValue::Compass(move_dir, dist) => {
                        let (dy, dx) = Instruction::compass_deltas(move_dir);
                        (y + dy * dist, x + dx * dist, dir)
                    },
                    ActionValue::Left(ddir) => {
                        (y, x, dir - ddir)
                    },
                    ActionValue::Right(ddir) => {
                        (y, x, dir + ddir)
                    },
                    ActionValue::Forward(dist) => {
                        let (dy, dx) = Instruction::compass_deltas(dir);
                        (y + dy * dist, x + dx * dist, dir)
                    },
                }
            });
        self.y = y1;
        self.x = x1;
        self.dir = dir1;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let actions: Vec<ActionValue> = Instruction::read_from_file("input/example1.txt")
            .unwrap()
            .iter()
            .map(Instruction::action)
            .collect();
        assert_eq!(vec![
            ActionValue::Forward(10),
            ActionValue::Compass(270, 3),
            ActionValue::Forward(7),
            ActionValue::Right(90),
            ActionValue::Forward(11),
        ], actions);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let instructions = Instruction::read_from_file("input/example99.txt");
        assert!(instructions.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let instructions = Instruction::read_from_file("input/bad1.txt");
        assert!(instructions.is_err());
    }

    #[test]
    fn test_parse_instruction() {
        assert_eq!(ActionValue::Compass(90, 40),
            "S40".parse::<Instruction>().unwrap().action());
        assert_eq!(ActionValue::Compass(0, 5),
            "E5".parse::<Instruction>().unwrap().action());
        assert_eq!(ActionValue::Compass(180, 77),
            "W77".parse::<Instruction>().unwrap().action());
        assert_eq!(ActionValue::Left(180),
            "L180".parse::<Instruction>().unwrap().action());
    }

    #[test]
    fn test_compass_deltas() {
        assert_eq!((0, -1), Instruction::compass_deltas(180));
        assert_eq!((-1, 0), Instruction::compass_deltas(-90));
    }

    #[test]
    #[should_panic]
    fn test_compass_deltas_bad() {
        let (_dy, _dx) = Instruction::compass_deltas(45);
    }

    #[test]
    fn test_follow_instructions() {
        let mut ferry = Ferry::read_from_file("input/example1.txt").unwrap();
        ferry.follow_instructions();
        assert_eq!(8, ferry.ns());
        assert_eq!(17, ferry.ew());
        assert_eq!(25, ferry.manhattan());
    }
}
