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

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Bus {
    pub in_service: bool,
    pub id: u32,
    pub pos: u32,
}

#[derive(Debug, Clone)]
pub struct BusSchedule {
    earliest_depart: u32,
    busses: Vec<Bus>,
}

impl Bus {
    /// Is referenced `bus` in service?
    pub fn in_service(bus: &&Bus) -> bool {
        bus.in_service
    }

    /// Construct from ID string and position. Non-numeric IDs indicate an
    /// out-of-service bus.
    pub fn from_id_pos(id: &str, pos: u32) -> Self {
        let (id, in_service): (u32, bool) = match id.parse() {
            Ok(id) => (id, true),
            Err(_) => (0, false),
        };
        Self { in_service, id, pos }
    }
}

impl FromStr for BusSchedule {
    type Err = Box<dyn error::Error>;

    fn from_str(block: &str) -> Result<Self> {
        let fields: Vec<&str> = block.trim().split("\n").take(2).collect();
        let earliest_depart: u32 = fields[0].parse()?;
        let busses: Vec<Bus> = fields[1]
            .split(',')
            .enumerate()
            .map(|(pos, id)| Bus::from_id_pos(id, pos as u32))
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

    /// Return list of in-service busses.
    #[must_use]
    pub fn in_service_busses(&self) -> Vec<Bus> {
        self.busses
            .iter()
            .filter(Bus::in_service)
            .copied()
            .collect()
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

    /// Find the next departing bus. Returns the bus ID and wait time.
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
            .filter(Bus::in_service)
            .map(|bus| BusSchedule::wait_time(self.earliest_depart, bus.id))
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
        assert_eq!(vec![
                Bus { in_service: true,  id: 7,  pos: 0 },
                Bus { in_service: true,  id: 13, pos: 1 },
                Bus { in_service: true,  id: 59, pos: 4 },
                Bus { in_service: true,  id: 31, pos: 6 },
                Bus { in_service: true,  id: 19, pos: 7 },
            ],
            schedule.in_service_busses()
        );
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
