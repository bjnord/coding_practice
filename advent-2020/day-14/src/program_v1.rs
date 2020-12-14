use crate::memory::Memory;
use std::error;
use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<InstructionV1> = result::Result<InstructionV1, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct InstructionV1Error(String);

impl fmt::Display for InstructionV1Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "InstructionV1 error: {}", self.0)
    }
}

impl error::Error for InstructionV1Error {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InstructionV1Value {
    Mask { or: u64, and: u64 },
    Mem { address: u64, value: u64 },
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct InstructionV1 {
    instruction: InstructionV1Value,
}

#[derive(Debug)]
pub struct ProgramV1 {
    instructions: Vec<InstructionV1>,
    memory: Memory,
    or_mask: u64,
    and_mask: u64,
}

impl FromStr for InstructionV1 {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let instruction = match &line[0..3] {
            "mas" => {
                let bitmap = scan_fmt!(line, "mask = {}", String)?;
                let (or, and) = InstructionV1::parse_mask(&bitmap)?;
                InstructionV1Value::Mask { or, and }
            },
            "mem" => {
                let (address, value) = scan_fmt!(line, "mem[{d}] = {d}", u64, u64)?;
                InstructionV1Value::Mem { address, value }
            },
            _ => {
                let e = format!("invalid instruction [{}]", line);
                return Err(InstructionV1Error(e).into());
            }
        };
        Ok(InstructionV1 { instruction })
    }
}

impl InstructionV1 {
    /// Return instruction value.
    #[cfg(test)]
    #[must_use]
    fn instruction(&self) -> InstructionV1Value {
        self.instruction
    }

    /// Read instructions from `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<Vec<InstructionV1>> {
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
    /// # use crate::program_v1::InstructionV1;
    /// let (or, and) = InstructionV1::parse_mask("XXXXXXXXXXXXXXXXXXXXXXXXXXXX0X1X1X0X").unwrap();
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

impl ProgramV1 {
    /// Return instruction values.
    #[cfg(test)]
    #[must_use]
    fn instruction_values(&self) -> Vec<InstructionV1Value> {
        self.instructions
            .iter()
            .map(InstructionV1::instruction)
            .collect()
    }

    /// Return `value` with OR and AND masks applied.
    #[must_use]
    pub fn masked_value(&self, value: u64) -> u64 {
        (value & self.and_mask) | self.or_mask
    }

    /// Return sum of all memory cells.
    #[must_use]
    pub fn memory_sum(&self) -> u64 {
        self.memory.sum()
    }

    /// Construct by reading instructions from path.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<ProgramV1> {
        let instructions = InstructionV1::read_from_file(path)?;
        Ok(Self { instructions, memory: Memory::new(), or_mask: 0, and_mask: 0 })
    }

    /// Run program.
    pub fn run(&mut self) {
        for inst in &self.instructions {
            match inst.instruction {
                InstructionV1Value::Mask { or, and } => {
                    self.or_mask = or;
                    self.and_mask = and;
                },
                InstructionV1Value::Mem { address, value } => {
                    self.memory.write(address, self.masked_value(value));
                },
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let program: ProgramV1 = ProgramV1::read_from_file("input/example1.txt").unwrap();
        assert_eq!(vec![
            InstructionV1Value::Mask { or: 0x000000040, and: 0xffffffffd },
            InstructionV1Value::Mem { address: 8, value: 11 },
            InstructionV1Value::Mem { address: 7, value: 101 },
            InstructionV1Value::Mem { address: 8, value: 0 },
        ], program.instruction_values());
    }

    #[test]
    fn test_read_from_file_no_file() {
        let instructions = InstructionV1::read_from_file("input/example99.txt");
        assert!(instructions.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let instructions = InstructionV1::read_from_file("input/bad1.txt");
        assert!(instructions.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mask() {
        let instruction = "mask = XXXXYXXXXXXXYXXXXXXXYXXXXXXXYXXXX0X1".parse::<InstructionV1>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mem_address() {
        let instruction = "mem[Y8] = 11".parse::<InstructionV1>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mem_value() {
        let instruction = "mem[8] = X11".parse::<InstructionV1>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_program_run() {
        let mut program: ProgramV1 = ProgramV1::read_from_file("input/example1.txt").unwrap();
        program.run();
        eprintln!("program = {:#?}", program);
        assert_eq!(165u64, program.memory_sum());
    }
}
