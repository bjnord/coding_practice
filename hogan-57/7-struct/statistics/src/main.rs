use std::fs::File;
use std::io::{BufRead, BufReader};

struct ValueList {
    values: Vec<i32>,
}

impl ValueList {
    #[allow(dead_code)]
    fn from_memory() -> ValueList {
        let mut values = Vec::new();
        values.push(100);
        values.push(200);
        values.push(950);
        values.push(300);
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
        // FIXME there should be a more elegant way of doing this
        let mut sum: f64 = 0.0;
        for n in &self.values {
            let f = *n as f64;
            sum += f;
        }
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
        // FIXME there should be a more elegant way of doing this
        let mut sum: f64 = 0.0;
        for n in &self.values {
            let f = *n as f64;
            sum += (f - mean).powi(2);
        }
        let mean_of_squares = sum / (self.count() as f64);
        mean_of_squares.sqrt()
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
