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
    North(i32),
    South(i32),
    East(i32),
    West(i32),
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
            'N' => ActionValue::North(value),
            'S' => ActionValue::South(value),
            'E' => ActionValue::East(value),
            'W' => ActionValue::West(value),
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
    /// Return instruction joltage value.
    #[must_use]
    pub fn action(&self) -> ActionValue {
        self.action
    }

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
            ActionValue::North(3),
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
        assert_eq!(ActionValue::South(40),
            "S40".parse::<Instruction>().unwrap().action());
        assert_eq!(ActionValue::East(5),
            "E5".parse::<Instruction>().unwrap().action());
        assert_eq!(ActionValue::West(77),
            "W77".parse::<Instruction>().unwrap().action());
        assert_eq!(ActionValue::Left(180),
            "L180".parse::<Instruction>().unwrap().action());
    }

    #[test]
    fn test_compass_deltas() {
        assert_eq!((1, 0), Instruction::compass_deltas(90));
        assert_eq!((0, -1), Instruction::compass_deltas(180));
        assert_eq!((-1, 0), Instruction::compass_deltas(-90));
    }

    #[test]
    #[should_panic]
    fn test_compass_deltas_bad() {
        let (_dy, _dx) = Instruction::compass_deltas(45);
    }
}
