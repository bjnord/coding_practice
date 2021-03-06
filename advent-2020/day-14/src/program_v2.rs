use crate::memory::Memory;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone)]
struct InstructionV2Error(String);

impl fmt::Display for InstructionV2Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "InstructionV2 error: {}", self.0)
    }
}

impl std::error::Error for InstructionV2Error {}

#[derive(Debug, Clone, PartialEq)]
pub enum InstructionV2Value {
    Mask { or: u64, float: Vec<usize> },
    Mem { address: u64, value: u64 },
}

#[derive(Debug, Clone, PartialEq)]
pub struct InstructionV2 {
    instruction: InstructionV2Value,
}

#[derive(Debug)]
pub struct ProgramV2 {
    instructions: Vec<InstructionV2>,
    memory: Memory,
    or_mask: u64,
    float_mask: Vec<usize>,
}

impl FromStr for InstructionV2 {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let instruction = match &line[0..3] {
            "mas" => {
                let bitmap = scan_fmt!(line, "mask = {}", String)?;
                let (or, float) = InstructionV2::parse_mask(&bitmap)?;
                InstructionV2Value::Mask { or, float }
            },
            "mem" => {
                let (address, value) = scan_fmt!(line, "mem[{d}] = {d}", u64, u64)?;
                InstructionV2Value::Mem { address, value }
            },
            _ => {
                let e = format!("invalid instruction [{}]", line);
                return Err(InstructionV2Error(e).into());
            }
        };
        Ok(InstructionV2 { instruction })
    }
}

impl InstructionV2 {
    #[cfg(test)]
    #[must_use]
    fn instruction(&self) -> InstructionV2Value {
        self.instruction.clone()
    }

    /// Read list of instructions from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<Vec<InstructionV2>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }

    /// Read list of instructions from `input` string.
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid instruction format.
    #[cfg(test)]
    pub fn from_input(input: &str) -> Result<Vec<InstructionV2>> {
        input.lines().map(str::parse).collect()
    }

    /// Return the OR and float masks, respectively, from a bitmap string.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the bitmask string is invalid.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_14::program_v2::InstructionV2;
    /// let (or, float) = InstructionV2::parse_mask("00000000000000000000000000X1011X100X").unwrap();
    /// assert_eq!(0x000000168, or);
    /// assert_eq!(vec![9, 4, 0], float);
    /// ```
    pub fn parse_mask(bitmap: &str) -> Result<(u64, Vec<usize>)> {
        let or_bitmap = str::replace(bitmap, "X", "0");
        let or_mask = u64::from_str_radix(&or_bitmap, 2)?;
        let mut float_mask: Vec<usize> = vec![];
        for (i, c) in bitmap.chars().enumerate() {
            if c == 'X' { float_mask.push(35 - i); }
        }
        Ok((or_mask, float_mask))
    }
}

impl ProgramV2 {
    #[cfg(test)]
    #[must_use]
    fn instruction_values(&self) -> Vec<InstructionV2Value> {
        self.instructions
            .iter()
            .map(InstructionV2::instruction)
            .collect()
    }

    /// Return all combinations of `address` with OR and float masks applied.
    #[must_use]
    pub fn masked_addresses(&self, address: u64) -> Vec<u64> {
        let addr = address | self.or_mask;
        let mut addresses: Vec<u64> = Vec::new();
        // there will be 2^N combinations of N `float_mask` bits
        // (combinations indexed as `ci`):
        for ci in 0u64..2u64.pow(self.float_mask.len() as u32) {
            let masked_addr = self.float_mask
                .iter()
                .enumerate()
                // do the N `float_mask` bit flips for this combination
                // (mask bit N indexed as `mn`):
                .fold(addr, |addr, (mn, bit)| {
                    // e.g. `float_mask` `bit==9` yields `bitmask=0x200`:
                    let bitmask: u64 = 2u64.pow(*bit as u32);
                    // check whether bit x/N is clear/set in this **combo**,
                    // then clear/set corresponding mask bit in **address**:
                    if (ci & 2u64.pow(mn as u32)) == 0 {
                        addr & !bitmask
                    } else {
                        addr | bitmask
                    }
                });
            addresses.push(masked_addr)
        }
        addresses
    }

    /// Return sum of all memory cell values.
    #[must_use]
    pub fn memory_sum(&self) -> u64 {
        self.memory.sum()
    }

    /// Construct by reading instructions from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid instruction format.
    pub fn read_from_file(path: &str) -> Result<ProgramV2> {
        let instructions = InstructionV2::read_from_file(path)?;
        Ok(Self { instructions, memory: Memory::new(), or_mask: 0, float_mask: vec![] })
    }

    /// Construct by reading instructions from `input` string.
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid instruction format.
    #[cfg(test)]
    pub fn from_input(input: &str) -> Result<ProgramV2> {
        let instructions = InstructionV2::from_input(input)?;
        Ok(Self { instructions, memory: Memory::new(), or_mask: 0, float_mask: vec![] })
    }

    /// Run program.
    pub fn run(&mut self) {
        for inst in &self.instructions {
            match &inst.instruction {
                InstructionV2Value::Mask { or, float } => {
                    self.or_mask = *or;
                    self.float_mask = float.clone();
                },
                InstructionV2Value::Mem { address, value } => {
                    for addr in self.masked_addresses(*address) {
                        self.memory.write(addr, *value);
                    }
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
        let program: ProgramV2 = ProgramV2::read_from_file("input/example2.txt").unwrap();
        assert_eq!(vec![
            InstructionV2Value::Mask { or: 0x000000012, float: vec![5, 0] },
            InstructionV2Value::Mem { address: 42, value: 100 },
            InstructionV2Value::Mask { or: 0x000000000, float: vec![3, 1, 0] },
            InstructionV2Value::Mem { address: 26, value: 1 },
        ], program.instruction_values());
    }

    #[test]
    fn test_read_from_file_no_file() {
        let instructions = InstructionV2::read_from_file("input/example99.txt");
        assert!(instructions.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let instructions = InstructionV2::read_from_file("input/bad1.txt");
        assert!(instructions.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mask() {
        let instruction = "mask = XXXXYXXXXXXXYXXXXXXXYXXXXXXXYXXXX0X1".parse::<InstructionV2>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mem_address() {
        let instruction = "mem[Y8] = 11".parse::<InstructionV2>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_parse_instruction_bad_mem_value() {
        let instruction = "mem[8] = X11".parse::<InstructionV2>();
        assert!(instruction.is_err());
    }

    #[test]
    fn test_program_run() {
        let mut program = ProgramV2::read_from_file("input/example2.txt").unwrap();
        program.run();
        assert_eq!(208u64, program.memory_sum());
    }

    #[test]
    fn test_masked_addresses() {
        let mut program = ProgramV2::from_input("mask = 000000000000000000000000000000X1001X").unwrap();
        program.run();
        assert_eq!(vec![26, 58, 27, 59], program.masked_addresses(42));
    }

    #[test]
    fn test_masked_addresses_2() {
        let mut program = ProgramV2::from_input("mask = 00000000000000000000000000000000X0XX").unwrap();
        program.run();
        assert_eq!(vec![16, 24, 18, 26, 17, 25, 19, 27], program.masked_addresses(26));
    }
}
