use std::collections::HashMap;

#[derive(Debug)]
pub struct Memory {
    cells: HashMap<u64, u64>,
}

impl Memory {
    pub fn new() -> Memory {
        Memory { cells: HashMap::new() }
    }

    /// Write `value` to `address` cell in memory.
    pub fn write(&mut self, address: u64, value: u64) {
        self.cells.insert(address, value);
    }

    /// Return sum of all cells in memory.
    #[must_use]
    pub fn sum(&self) -> u64 {
        self.cells
            .values()
            .sum()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_memory() {
        let mut memory = Memory::new();
        memory.write(6, 1);
        memory.write(2, 2);
        memory.write(9, 6);
        assert_eq!(9u64, memory.sum());
    }
}
