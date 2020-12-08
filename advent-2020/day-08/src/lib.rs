#![warn(clippy::pedantic)]

use std::error;
use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Program> = result::Result<Program, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct InstructionError(String);

impl fmt::Display for InstructionError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Instruction error: {}", self.0)
    }
}

impl error::Error for InstructionError {}

#[derive(Debug)]
pub struct Instruction {
    opcode: String,
    arg: i32,
}

#[derive(Debug)]
pub struct Program {
    instructions: Vec<Instruction>,
}

pub enum HaltType {
    Ended,
    Looped {acc: i32},
}

impl FromStr for Program {
    type Err = Box<dyn error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let instructions = input
            .lines()
            .map(|line| {
                let f: Vec<&str> = line.split(' ').collect();
                Instruction {
                    opcode: String::from(f[0]),
                    arg: f[1].parse::<i32>().unwrap(),
                }
            })
            .collect();
        Ok(Program { instructions })
    }
}

impl Program {
    /// Read program from a file.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened.
    pub fn read_from_file(path: &str) -> Result<Program> {
        let s: String = fs::read_to_string(path)?;
        s.parse()
    }

    /// Run program until it loops (the same PC is seen again) or ends
    /// (PC goes beyond the program). Returns the accumulator value
    /// for the former case.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_08::{Program, HaltType};
    /// let program = Program::read_from_file("input/example1.txt").unwrap();
    /// let acc = match program.run_until_halt() {
    ///     HaltType::Looped { acc } => acc,
    ///     _ => panic!("program did not loop"),
    /// };
    /// assert_eq!(5, acc);
    ///
    /// let program = Program::read_from_file("input/example2.txt").unwrap();
    /// let ended = match program.run_until_halt() {
    ///     HaltType::Ended => true,
    ///     _ => false,
    /// };
    /// assert_eq!(true, ended);
    /// ```
    pub fn run_until_halt(&self) -> HaltType {
        let mut acc: i32 = 0;
        let mut pc: usize = 0;
        let mut seen = [false; 1024];
        let program_len = self.instructions.len();
        while !seen[pc] && pc < program_len {
            let inst = &self.instructions[pc];
            seen[pc] = true;
            match &inst.opcode[..] {
                "acc" => {
                    acc += inst.arg;
                    pc += 1;
                },
                "jmp" => {
                    if inst.arg.is_negative() {
                        pc -= inst.arg.wrapping_abs() as usize;
                    } else {
                        pc += inst.arg as usize;
                    }
                },
                _ => {  // including "nop"
                    pc += 1;
                },
            }
        }
        match pc {
            pc if seen[pc] => HaltType::Looped { acc },
            _ => HaltType::Ended,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file_bad_path() {
        let result = Program::read_from_file("input/example99.txt");
        assert!(result.is_err());
    }
}
