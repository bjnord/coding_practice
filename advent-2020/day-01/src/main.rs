use custom_error::custom_error;
use itertools::Itertools;
use std::error::Error;
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
    let entries = read_entries("input/input.txt").unwrap();
    let solution = find_solution(entries, 2, EXPECTED).unwrap();
    println!("== PART 1 ==");
    println!("{} + {} = {}", solution[0], solution[1], EXPECTED);
    println!("{} * {} = {} (should be 776064)", solution[0], solution[1], solution[0] * solution[1]);
}

/// Output solution for part 2.
fn part2() {
    let entries = read_entries("input/input.txt").unwrap();
    let solution = find_solution(entries, 3, EXPECTED).unwrap();
    println!("== PART 2 ==");
    println!("{} + {} + {} = {}", solution[0], solution[1], solution[2], EXPECTED);
    println!("{} * {} * {} = {} (should be 6964490)", solution[0], solution[1], solution[2], solution[0] * solution[1] * solution[2]);
}

/// Read expense report entries from `filename`.
///
/// The file should have one integer per line.
fn read_entries(filename: &str) -> Result<Vec<i32>, Box<dyn Error>> {
    let reader = BufReader::new(File::open(filename)?);
    // FIXME instead of `parse().unwrap()`, should return error to caller
    Ok(reader.lines().map(|line| line.unwrap().parse::<i32>().unwrap()).collect())
}

/// Find `n` values from `entries` whose sum is `expected`.
fn find_solution(entries: Vec<i32>, n: usize, expected: i32) -> Result<Vec<i32>, SolutionError> {
    for p in entries.iter().combinations(n) {
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
    fn test_read_entries() {
        let entries = read_entries("input/example1.txt").unwrap();
        assert_eq!(vec![1721, 979, 366, 299, 675, 1456], entries);
    }

    #[test]
    fn test_read_entries_no_file() {
        let entries = read_entries("input/example99.txt");
        assert!(entries.is_err());
    }

    #[test]
    fn test_find_solution_for_2() {
        let entries = read_entries("input/example1.txt").unwrap();
        let solution = find_solution(entries, 2, EXPECTED).unwrap();
        assert_eq!(2, solution.len());
        assert_eq!(514579, solution[0] * solution[1]);
    }

    #[test]
    fn test_find_solution_for_3() {
        let entries = read_entries("input/example1.txt").unwrap();
        let solution = find_solution(entries, 3, EXPECTED).unwrap();
        assert_eq!(3, solution.len());
        assert_eq!(241861950, solution[0] * solution[1] * solution[2]);
    }

    #[test]
    fn test_no_solution_found() {
        let entries = vec![1, 2, 3, 4, 5];
        let result = find_solution(entries, 2, EXPECTED);
        assert_eq!(result.err().unwrap(), SolutionError::NotFound{expected: EXPECTED});
    }
}
