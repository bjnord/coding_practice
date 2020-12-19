use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Copy)]
pub struct Adapter {
    joltage: u32,
}

#[derive(Debug)]
pub struct AdapterSet {
    adapters: Vec<Adapter>,
    builtin_adapter: Adapter,
}

impl FromStr for Adapter {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let joltage: u32 = line.parse()?;
        Ok(Self { joltage })
    }
}

impl Adapter {
    /// Construct adapter from joltage value.
    #[must_use]
    pub fn from_joltage(joltage: u32) -> Adapter {
        Adapter { joltage }
    }

    /// Return adapter joltage value.
    #[must_use]
    #[allow(clippy::trivially_copy_pass_by_ref)]
    pub fn joltage(&self) -> u32 {
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

    #[must_use]
    pub fn joltages(&self) -> Vec<u32> {
        let mut values: Vec<u32> = self.adapters
            .iter()
            .map(Adapter::joltage)
            .collect();
        values.push(self.builtin_adapter.joltage());
        values.sort();
        values
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
        let joltages = self.joltages();
        let mut acc: u32 = 0;
        joltages.into_iter().fold((0, 0), |(one, three), j| {
            match j {
                j if (j - acc) == 1 => { acc += 1; (one + 1, three) },
                j if (j - acc) == 3 => { acc += 3; (one, three + 1) },
                _ => (one, three),
            }
        })
    }

    /// Count adapter arrangements. Returns the number of ways the adapters
    /// can be connected correctly (without necessarily using them all).
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_10::AdapterSet;
    /// let adapter_set = AdapterSet::read_from_file("input/example1.txt")
    ///     .unwrap();
    /// assert_eq!(8, adapter_set.adapter_arrangements());
    /// ```
    #[must_use]
    pub fn adapter_arrangements(&self) -> u64 {
        let joltages = self.joltages();
        let mut start = 0_u32;
        let mut end = 0_u32;
        joltages.iter().fold(1_u64, |mut choices, &next| {
            let gap = next - end;
            if gap > 3 {
                let s = format!("found adapter greater than +3 start={} end={} next={} gap={}", start, end, next, gap);
                panic!(s);
            }
            if gap > 1 {
                choices *= AdapterSet::adapter_choices(start, end);
                start = next;
            }
            end = next;
            choices
        })
    }

    #[allow(clippy::cast_sign_loss)]
    fn adapter_choices(start: u32, end: u32) -> u64 {
        if end < start {
            panic!("end < start");
        }
        let gap = (end - start) as usize;
        // these values were calculated by hand; see `README.md`
        let choices: Vec<u64> = vec![1, 1, 2, 4, 7, 11];
        if gap >= choices.len() {
            panic!("gap {} not supported", gap);
        }
        choices[gap]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let joltages: Vec<u32> = Adapter::read_from_file("input/example0.txt")
            .unwrap()
            .iter()
            .map(Adapter::joltage)
            .collect();
        assert_eq!(vec![1721, 979, 366, 299, 675, 1456], joltages);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let joltages = Adapter::read_from_file("input/example99.txt");
        assert!(joltages.is_err());
    }

    #[test]
    fn test_read_from_file_bad_file() {
        let joltages = Adapter::read_from_file("input/bad1.txt");
        assert!(joltages.is_err());
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

    #[test]
    fn test_adapter_arrangements_2() {
        let adapter_set = AdapterSet::read_from_file("input/example2.txt")
            .unwrap();
        assert_eq!(19208, adapter_set.adapter_arrangements());
    }

    #[test]
    fn test_adapter_choices() {
        // these are in example #1:
        assert_eq!(1, AdapterSet::adapter_choices(0, 1));    // gap=1
        assert_eq!(2, AdapterSet::adapter_choices(10, 12));  // gap=2
        assert_eq!(4, AdapterSet::adapter_choices(4, 7));    // gap=3
        // this is in example #2:
        assert_eq!(7, AdapterSet::adapter_choices(45, 49));  // gap=4
        // these aren't in the examples:
        assert_eq!(1, AdapterSet::adapter_choices(0, 0));    // gap=0
        assert_eq!(11, AdapterSet::adapter_choices(44, 49)); // gap=5
    }

    #[test]
    #[should_panic]
    fn test_adapter_choices_end_start() {
        AdapterSet::adapter_choices(1, 0);
    }
}
