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
    pub pos: usize,
}

#[derive(Debug, Clone)]
pub struct BusSchedule {
    earliest_depart: u32,
    busses: Vec<Bus>,
}

impl Bus {
    /// Is referenced `bus` in service?
    #[must_use]
    #[allow(clippy::trivially_copy_pass_by_ref)]
    pub fn in_service(bus: &&Bus) -> bool {
        bus.in_service
    }

    /// Construct from ID string and position. Non-numeric IDs indicate an
    /// out-of-service bus.
    #[must_use]
    pub fn from_id_pos(id: &str, pos: usize) -> Self {
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
        let fields: Vec<&str> = block.trim().split('\n').take(2).collect();
        let earliest_depart: u32 = fields[0].parse()?;
        let busses: Vec<Bus> = fields[1]
            .split(',')
            .enumerate()
            .map(|(pos, id)| Bus::from_id_pos(id, pos))
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
    #[must_use]
    pub fn next_bus(&self) -> (u32, u32) {
        let maxx = self.busses
            .iter()
            .filter(Bus::in_service)
            .map(|bus| BusSchedule::wait_time(self.earliest_depart, bus.id))
            .max_by(|&a, &b| b.1.cmp(&a.1))
            .unwrap();
        maxx
    }

    fn wait_time(earliest_depart: u32, bus_id: u32) -> (u32, u32) {
        let next_depart = ((earliest_depart / bus_id) + 1) * bus_id;
        (bus_id, next_depart - earliest_depart)
    }

    /// Find the earliest time at which the busses leave one after the
    /// other, 1 second apart.
    #[must_use]
    pub fn earliest_staggered_time(&self) -> u64 {
        let mut i = self.busses.iter().filter(Bus::in_service);
        let first = i.next().unwrap();
        //let mut this_modu: u64;
        //let mut this_rem: u64;
        let mut next_modu = u64::from(first.id);
        let mut next_rem = first.pos as u64;
        let mut next_mult = next_modu;
        let mut next_add = next_rem;
        for bus in i {
            //eprintln!("nextmod{} nextrem{} bus = {:?}", next_modu, next_rem, bus);
            //this_modu = next_modu;
            //this_rem = next_rem;
            next_modu = u64::from(bus.id);
            next_rem = bus.pos as u64;
            let sol_rem = BusSchedule::solve_congruence(next_mult, next_add, next_rem, next_modu);
            //println!("loop       j={} mod={}", sol_rem, next_modu);
            let tuple = BusSchedule::substitute_congruence(next_modu, sol_rem, next_mult, next_add);
            next_mult = tuple.0;
            next_add = tuple.1;
            //println!("           this=(m{}, r{}) next=(m{}, a{})", this_modu, this_rem, next_mult, next_add);
        }
        //println!("solution   m{} - r{} = {}", next_mult, next_add, next_mult - next_add);
        next_mult - next_add
    }

    /// Find reverse-modulo of congruence. See
    /// [this page](https://brilliant.org/wiki/chinese-remainder-theorem/).
    #[must_use]
    pub fn solve_congruence(mult: u64, add: u64, rem: u64, modu: u64) -> u64 {
        for j in 0..u64::MAX {
            if (mult * j + add).rem_euclid(modu) == rem {
                return j;
            }
        }
        u64::MAX
    }

    /// Substitute one congruence into another. See
    /// [this page](https://brilliant.org/wiki/chinese-remainder-theorem/).
    #[must_use]
    pub fn substitute_congruence(mult_inner: u64, add_inner: u64, mult: u64, add: u64) -> (u64, u64) {
        let new_mult = mult * mult_inner;
        let new_add = mult * add_inner + add;
        (new_mult, new_add)
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

    #[test]
    fn test_earliest_staggered_time() {
        let schedule: BusSchedule = "0\n7,13,x,x,59,x,31,19\n".parse().unwrap();
        assert_eq!(1068781, schedule.earliest_staggered_time());
    }

    #[test]
    fn test_earliest_staggered_time_2() {
        let schedule: BusSchedule = "0\n17,x,13,19\n".parse().unwrap();
        assert_eq!(3417, schedule.earliest_staggered_time());
    }

    #[test]
    fn test_earliest_staggered_time_3() {
        let schedule: BusSchedule = "0\n67,7,59,61\n".parse().unwrap();
        assert_eq!(754018, schedule.earliest_staggered_time());
    }

    #[test]
    fn test_earliest_staggered_time_4() {
        let schedule: BusSchedule = "0\n67,x,7,59,61\n".parse().unwrap();
        assert_eq!(779210, schedule.earliest_staggered_time());
    }

    #[test]
    fn test_earliest_staggered_time_5() {
        let schedule: BusSchedule = "0\n67,7,x,59,61\n".parse().unwrap();
        assert_eq!(1261476, schedule.earliest_staggered_time());
    }

    #[test]
    fn test_earliest_staggered_time_6() {
        let schedule: BusSchedule = "0\n1789,37,47,1889\n".parse().unwrap();
        assert_eq!(1202161486, schedule.earliest_staggered_time());
    }
}
