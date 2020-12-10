use std::error;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<Adapter> = result::Result<Adapter, Box<dyn error::Error>>;

#[derive(Debug, Clone, Copy)]
pub struct Adapter {
    joltage: i32,
}

#[derive(Debug)]
pub struct AdapterSet {
    adapters: Vec<Adapter>,
    builtin_adapter: Adapter,
}

impl FromStr for Adapter {
    type Err = Box<dyn error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let joltage: i32 = line.parse()?;
        Ok(Self { joltage })
    }
}

impl Adapter {
    /// Construct adapter from joltage value.
    #[must_use]
    pub fn from_joltage(joltage: i32) -> Adapter {
        Adapter { joltage }
    }

    /// Return adapter joltage value.
    #[must_use]
    #[allow(clippy::trivially_copy_pass_by_ref)]
    pub fn joltage(&self) -> i32 {
        self.joltage
    }

    /// Read adapters from `path`. The file should have one integer per
    /// line.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid integer format.
    pub fn read_from_file(path: &str) -> Result<Vec<Adapter>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }
}

impl AdapterSet {
    /// Construct by reading adapters from path. The file should have one
    /// integer per line.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid integer format.
    pub fn read_from_file(path: &str) -> Result<AdapterSet> {
        let adapters = Adapter::read_from_file(path)?;
        let max_joltage = adapters.iter().map(Adapter::joltage).max().unwrap();
        let builtin_adapter = Adapter::from_joltage(max_joltage + 3);
        Ok(Self { adapters, builtin_adapter })
    }

    /// Count adapter usage. Returns the count of adapters with a 1-jolt
    /// and 3-jolt difference, respectively, when ALL adapters are
    /// connected.
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_10::AdapterSet;
    /// let adapter_set = AdapterSet::read_from_file("input/example1.txt")
    ///     .unwrap();
    /// assert_eq!((7, 5), adapter_set.adapter_usage());
    /// ```
    #[must_use]
    pub fn adapter_usage(&self) -> (usize, usize)
    {
        let mut values: Vec<i32> = self.adapters
            .iter()
            .map(Adapter::joltage)
            .collect();
        values.push(self.builtin_adapter.joltage());
        values.sort();
        let mut acc: i32 = 0;
        values.into_iter().fold((0, 0), |(one, three), j| {
            match j {
                j if (j - acc) == 1 => { acc += 1; (one + 1, three) },
                j if (j - acc) == 3 => { acc += 3; (one, three + 1) },
                _ => (one, three),
            }
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let joltages: Vec<i32> = Adapter::read_from_file("input/example0.txt")
            .unwrap()
            .iter()
            .map(Adapter::joltage)
            .collect();
        assert_eq!(vec![1721, 979, 366, 299, 675, 1456], joltages);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let entries = Adapter::read_from_file("input/example99.txt");
        assert!(entries.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let entries = Adapter::read_from_file("input/bad1.txt");
        assert!(entries.is_err());
    }

    #[test]
    fn test_builtin_adapter() {
        let adapter_set = AdapterSet::read_from_file("input/example1.txt")
            .unwrap();
        assert_eq!(22, adapter_set.builtin_adapter.joltage());
    }

    #[test]
    fn test_adapter_usage_2() {
        let adapter_set = AdapterSet::read_from_file("input/example2.txt")
            .unwrap();
        assert_eq!((22, 10), adapter_set.adapter_usage());
    }
}
