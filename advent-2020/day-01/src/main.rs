use itertools::Itertools;
use std::fs::File;
use std::io::{BufRead, BufReader};

const EXPECT: i32 = 2020;

fn main() {
    let values = read_values("input/input.txt");
    let solution = find_solution(values, 2, EXPECT);
    println!("== PART 1 ==");
    println!("{} + {} = {}", solution[0], solution[1], EXPECT);
    println!("{} * {} = {}", solution[0], solution[1], solution[0] * solution[1]);
}

fn read_values(filename: &str) -> Vec<i32> {
    let reader = BufReader::new(File::open(filename).expect("Cannot open file"));
    let mut values = Vec::new();
    for line in reader.lines() {
        match line {
            Ok(content) => values.push(content.parse::<i32>().unwrap()),
            Err(e) => eprintln!("line read error: {}", e),
        }
    }
    values
}

fn find_solution(values: Vec<i32>, choose: usize, expect: i32) -> Vec<i32> {
    for p in values.iter().permutations(choose) {
        if p.iter().fold(0, |acc, x| acc + *x) == expect {
            // FIXME this is a hack; should copy p to new vector of same length
            match choose {
                2 => return vec![*p[0], *p[1]],
                _ => {},
            }
        }
    }
    vec![]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_find_solution_for_2() {
        let values = read_values("input/example1.txt");
        let solution = find_solution(values, 2, EXPECT);
        assert_eq!(2, solution.len());
        assert_eq!(514579, solution[0] * solution[1]);
    }
}
