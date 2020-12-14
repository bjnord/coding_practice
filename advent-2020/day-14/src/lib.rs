#[macro_use] extern crate scan_fmt;
use std::collections::HashMap;
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
pub enum InstructionValue {
    Mask { or: u64, and: u64 },
    Mem { address: u64, value: u64 },
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Instruction {
    instruction: InstructionValue,
}

#[derive(Debug)]
struct Memory {
    cells: HashMap<u64, u64>,
}

#[derive(Debug)]
pub struct Program {
    instructions: Vec<Instruction>,
    memory: Memory,
    or_mask: u64,
    and_mask: u64,
}

impl FromStr for Instruction {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let instruction = match &line[0..3] {
            "mas" => {
                let bitmap = scan_fmt!(line, "mask = {}", String)?;
                let (or, and) = Instruction::parse_mask(&bitmap)?;
                InstructionValue::Mask { or, and }
            },
            "mem" => {
                let (address, value) = scan_fmt!(line, "mem[{d}] = {d}", u64, u64)?;
                InstructionValue::Mem { address, value }
            },
            _ => {
                let e = format!("invalid instruction [{}]", line);
                return Err(InstructionError(e).into());
            }
        };
        Ok(Instruction { instruction })
    }
}

impl Instruction {
    /// Return instruction value.
    #[must_use]
    pub fn instruction(&self) -> InstructionValue {
        self.instruction
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

    /// Return the OR and AND masks, respectively, from a bitmap string.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the bitmask string is invalid.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_14::Instruction;
    /// let (or, and) = Instruction::parse_mask("XXXXXXXXXXXXXXXXXXXXXXXXXXXX0X1X1X0X").unwrap();
    /// assert_eq!(or, 0x000000028);
    /// assert_eq!(and, 0xfffffff7d);
    /// ```
    pub fn parse_mask(bitmap: &str) -> Result<(u64, u64)> {
        let or_bitmap = str::replace(bitmap, "X", "0");
        let or_mask = u64::from_str_radix(&or_bitmap, 2)?;
        let and_bitmap = str::replace(bitmap, "X", "1");
        let and_mask = u64::from_str_radix(&and_bitmap, 2)?;
        Ok((or_mask, and_mask))
    }
}

impl Program {
    /// Return instruction values.
    #[must_use]
    pub fn instruction_values(&self) -> Vec<InstructionValue> {
        self.instructions
            .iter()
            .map(Instruction::instruction)
            .collect()
    }

    /// Construct by reading instructions from path.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<Program> {
        let instructions = Instruction::read_from_file(path)?;
        Ok(Self { instructions, memory: Memory::new(), or_mask: 0, and_mask: 0 })
    }
}

impl Memory {
    fn new() -> Memory {
        Memory { cells: HashMap::new() }
    }

    /// Write `value` to `address` cell in memory.
    fn write(&mut self, address: u64, value: u64) {
        self.cells.insert(address, value);
    }

    /// Return sum of all cells in memory.
    #[must_use]
    fn sum(&self) -> u64 {
        self.cells
            .values()
            .sum()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let program: Program = Program::read_from_file("input/example1.txt").unwrap();
        assert_eq!(vec![
            InstructionValue::Mask { or: 0x000000040, and: 0xffffffffd },
            InstructionValue::Mem { address: 8, value: 11 },
            InstructionValue::Mem { address: 7, value: 101 },
            InstructionValue::Mem { address: 8, value: 0 },
        ], program.instruction_values());
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
    fn test_parse_instruction_bad_mask() {
        let instruction = "mask = XXXXYXXXXXXXYXXXXXXXYXXXXXXXYXXXX0X1".parse::<Instruction>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mem_address() {
        let instruction = "mem[Y8] = 11".parse::<Instruction>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mem_value() {
        let instruction = "mem[8] = X11".parse::<Instruction>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_memory() {
        let mut memory = Memory::new();
        memory.write(6, 1);
        memory.write(2, 2);
        memory.write(9, 6);
        assert_eq!(9u64, memory.sum());
    }
}
