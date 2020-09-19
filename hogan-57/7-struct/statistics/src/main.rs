use std::fs::File;
use std::io::{BufRead, BufReader};

struct ValueList {
    values: Vec<i32>,
}

impl ValueList {
    #[cfg(test)]
    fn from_array(a: &[i32]) -> ValueList {
        let mut values = Vec::new();
        for v in a.iter() {
            values.push(*v);
        }
        ValueList {values}
    }

    fn from_file(filename: &str) -> ValueList {
        let mut values = Vec::new();
        let reader = BufReader::new(File::open(filename).expect("Cannot open file"));
        for line in reader.lines() {
            match line.unwrap().parse::<i32>() {
                Ok(n) => { values.push(n); },
                Err(e) => { println!("That is not a valid number: {}", e); },
            }
        }
        ValueList {values}
    }

    fn count(&self) -> usize {
        self.values.len()
    }

    fn mean(&self) -> f64 {
        let sum: f64 = self.values.iter().fold(0, |acc, x| acc + x) as f64;
        sum / (self.count() as f64)
    }

    fn min(&self) -> i32 {
        let mut min = i32::MAX;
        for n in &self.values {
            if *n < min {
                min = *n;
            }
        }
        min
    }

    fn max(&self) -> i32 {
        let mut max = i32::MIN;
        for n in &self.values {
            if *n > max {
                max = *n;
            }
        }
        max
    }

    fn std_dev(&self) -> f64 {
        let mean = self.mean();
        let sum: f64 = self.values.iter().fold(0.0, |acc, x| acc + (*x as f64 - mean).powi(2));
        let mean_of_squares = sum / (self.count() as f64);
        mean_of_squares.sqrt()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn calculate_mean() {
        let vl = ValueList::from_array(&[100, 200, 1000, 300]);
        assert!((400.0 - vl.mean()).abs() < 0.000001);
    }

    #[test]
    fn calculate_min() {
        let vl = ValueList::from_array(&[100, 200, 1000, 300]);
        assert_eq!(100, vl.min());
    }

    #[test]
    fn calculate_max() {
        let vl = ValueList::from_array(&[100, 200, 1000, 300]);
        assert_eq!(1000, vl.max());
    }

    #[test]
    fn calculate_std_dev() {
        let vl = ValueList::from_array(&[100, 200, 1000, 300]);
        assert!((353.553390 - vl.std_dev()).abs() < 0.000001);
    }
}

fn main() {
    let value_list = ValueList::from_file("input.txt");
    //let value_list = ValueList::from_memory();
    println!("There are {} values.", value_list.count());
    // TODO output "Numbers: n1, n2, ... nn" using Display trait
    println!("The average is {}.", value_list.mean());
    println!("The minimum is {}.", value_list.min());
    println!("The maximum is {}.", value_list.max());
    println!("The standard deviation is {}.", value_list.std_dev());
}
