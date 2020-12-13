use std::error;
use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<BusSchedule> = result::Result<BusSchedule, Box<dyn error::Error>>;

#[derive(Debug, Clone)]
struct BusScheduleError(String);

impl fmt::Display for BusScheduleError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "BusSchedule error: {}", self.0)
    }
}

impl error::Error for BusScheduleError {}

#[derive(Debug, Clone)]
pub struct BusSchedule {
    earliest_depart: u32,
    busses: Vec<u32>,
}

impl FromStr for BusSchedule {
    type Err = Box<dyn error::Error>;

    fn from_str(block: &str) -> Result<Self> {
        let fields: Vec<&str> = block.trim().split("\n").take(2).collect();
        let earliest_depart: u32 = fields[0].parse()?;
        let busses: Vec<u32> = fields[1]
            .split(',')
            .filter(|&id| id != "x")
            .map(|id| id.parse().unwrap())
            .collect();
        Ok(Self { earliest_depart, busses })
    }
}

impl BusSchedule {
    /// Return earliest departure time.
    #[must_use]
    pub fn earliest_depart(&self) -> u32 {
        self.earliest_depart
    }

    /// Return list of busses.
    #[must_use]
    pub fn busses(&self) -> Vec<u32> {
        self.busses.clone()
    }

    /// Read bus schedule from file.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if
    /// an input line has an invalid format.
    pub fn read_from_file(path: &str) -> Result<BusSchedule> {
        let s: String = fs::read_to_string(path)?;
        s.parse()
    }

    /// Find the next bus. Returns the bus ID and wait time.
    ///
    /// Examples
    ///
    /// ```
    /// # use day_13::BusSchedule;
    /// let schedule = BusSchedule::read_from_file("input/example1.txt").unwrap();
    /// assert_eq!((59, 5), schedule.next_bus());
    /// ```
    pub fn next_bus(&self) -> (u32, u32) {
        let maxx = self.busses
            .iter()
            .map(|&id| BusSchedule::wait_time(self.earliest_depart, id))
            .max_by(|&a, &b| b.1.cmp(&a.1))
            .unwrap();
        eprintln!("maxx ({}, {})", maxx.0, maxx.1);
        maxx
    }

    fn wait_time(earliest_depart: u32, bus_id: u32) -> (u32, u32) {
        let next_depart = ((earliest_depart / bus_id) + 1) * bus_id;
        (bus_id, next_depart - earliest_depart)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let schedule = BusSchedule::read_from_file("input/example1.txt").unwrap();
        assert_eq!(939, schedule.earliest_depart());
        assert_eq!(vec![7, 13, 59, 31, 19], schedule.busses());
    }

    #[test]
    fn test_read_from_file_no_file() {
        let schedule = BusSchedule::read_from_file("input/example99.txt");
        assert!(schedule.is_err());
    }

    #[test]
    fn test_read_from_file_bad_format() {
        let schedule = BusSchedule::read_from_file("input/bad1.txt");
        assert!(schedule.is_err());
    }
}
