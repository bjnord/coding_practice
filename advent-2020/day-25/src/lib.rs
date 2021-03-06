use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Device {
    public_key: u64,
    loop_size: usize,
}

impl FromStr for Device {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let public_key: u64 = input.parse()?;
        Ok(Self { public_key, loop_size: 0 })
    }
}

impl fmt::Display for Device {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Public Key {}\nLoop Size {}", self.public_key, self.loop_size)
    }
}

impl Device {
    /// Return the device's public key.
    pub fn public_key(&self) -> u64 {
        self.public_key
    }

    /// Construct by reading devices from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<Vec<Device>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }

    /// Determine the device's loop size.
    pub fn set_loop_size(&mut self) {
        let subject = 7_u64;
        let mut value = 1_u64;
        for loop_size in 1..usize::MAX {
            Device::transform(&mut value, subject);
            if value == self.public_key {
                self.loop_size = loop_size;
                break;
            }
        }
    }

    /// Determine the encryption key.
    pub fn encryption_key(&mut self, other_public_key: u64) -> u64 {
        let subject = other_public_key;
        let mut value = 1_u64;
        for _ in 1..=self.loop_size {
            Device::transform(&mut value, subject);
        }
        value
    }

    fn transform(value: &mut u64, subject: u64) {
        *value *= subject;
        *value = value.rem_euclid(20201227);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let devices = Device::read_from_file("input/example1.txt").unwrap();
        assert_eq!(2, devices.len());
        assert_eq!(5764801, devices[0].public_key());
    }

    #[test]
    fn test_read_from_file_no_file() {
        match Device::read_from_file("input/example99.txt") {
            Err(e) => assert!(e.to_string().contains("No such file")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_invalid_line() {
        match Device::read_from_file("input/bad1.txt") {
            Err(e) => assert!(e.to_string().contains("invalid digit")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_set_loop_size() {
        let mut devices = Device::read_from_file("input/example1.txt").unwrap();
        devices[0].set_loop_size();
        assert_eq!(8, devices[0].loop_size);
        devices[1].set_loop_size();
        assert_eq!(11, devices[1].loop_size);
    }

    #[test]
    fn test_encryption_key() {
        let mut devices = Device::read_from_file("input/example1.txt").unwrap();
        devices[0].set_loop_size();
        let public_key_1 = devices[1].public_key();
        assert_eq!(14897079, devices[0].encryption_key(public_key_1));
        devices[1].set_loop_size();
        let public_key_0 = devices[0].public_key();
        assert_eq!(14897079, devices[1].encryption_key(public_key_0));
    }
}
