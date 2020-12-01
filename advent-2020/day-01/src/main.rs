use custom_error::custom_error;
use itertools::Itertools;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::time::Instant;

const EXPECTED: i32 = 2020;

custom_error!{#[derive(PartialEq)]
    SolutionError
    NotFound{expected: i32} = "no solution found for {expected}"
}

fn main() {
    let start = Instant::now();
    part1();
    part2();
    let duration = start.elapsed();
    eprintln!("Finished after {:?}", duration);
}

/// Output solution for part 1.
fn part1() {
    let values = read_values("input/input.txt");
    let solution = find_solution(values, 2, EXPECTED).unwrap();
    println!("== PART 1 ==");
    println!("{} + {} = {}", solution[0], solution[1], EXPECTED);
    println!("{} * {} = {} (should be 776064)", solution[0], solution[1], solution[0] * solution[1]);
}

/// Output solution for part 2.
fn part2() {
    let values = read_values("input/input.txt");
    let solution = find_solution(values, 3, EXPECTED).unwrap();
    println!("== PART 2 ==");
    println!("{} + {} + {} = {}", solution[0], solution[1], solution[2], EXPECTED);
    println!("{} * {} * {} = {} (should be 6964490)", solution[0], solution[1], solution[2], solution[0] * solution[1] * solution[2]);
}

/// Read values from `filename`.
///
/// The file should have one integer per line.
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

/// Find `choose` values from `values` whose sum is `expected`.
fn find_solution(values: Vec<i32>, choose: usize, expected: i32) -> Result<Vec<i32>, SolutionError> {
    for p in values.iter().combinations(choose) {
        if p.iter().fold(0, |acc, x| acc + *x) == expected {
            // clone vector, copying each &i32 to new i32
            return Ok(p.iter().map(|x| **x).collect());
        }
    }
    Err(SolutionError::NotFound{expected})
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_find_solution_for_2() {
        let values = read_values("input/example1.txt");
        let solution = find_solution(values, 2, EXPECTED).unwrap();
        assert_eq!(2, solution.len());
        assert_eq!(514579, solution[0] * solution[1]);
    }

    #[test]
    fn test_find_solution_for_3() {
        let values = read_values("input/example1.txt");
        let solution = find_solution(values, 3, EXPECTED).unwrap();
        assert_eq!(3, solution.len());
        assert_eq!(241861950, solution[0] * solution[1] * solution[2]);
    }

    #[test]
    fn test_no_solution_found() {
        let values = vec![1, 2, 3, 4, 5];
        let result = find_solution(values, 2, EXPECTED);
        assert_eq!(result.err().unwrap(), SolutionError::NotFound{expected: EXPECTED});
    }
}
