#![warn(clippy::pedantic)]

use day_01::{Entry, ENTRY_SUM};
use std::time::Instant;

fn main() {
    let start = Instant::now();
    part1();
    part2();
    let duration = start.elapsed();
    eprintln!("Finished after {:?}", duration);
}

/// Output solution for part 1.
fn part1() {
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    let solution = Entry::find_solution(&entries, 2, ENTRY_SUM).unwrap();
    let prod = solution.iter().product::<i32>();
    println!("== PART 1 ==");
    println!("{} + {} = {}", solution[0], solution[1], ENTRY_SUM);
    println!("{} * {} = {} (should be 776064)", solution[0], solution[1], prod);
}

/// Output solution for part 2.
fn part2() {
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    let solution = Entry::find_solution(&entries, 3, ENTRY_SUM).unwrap();
    let prod = solution.iter().product::<i32>();
    println!("== PART 2 ==");
    println!("{} + {} + {} = {}", solution[0], solution[1], solution[2], ENTRY_SUM);
    println!("{} * {} * {} = {} (should be 6964490)", solution[0], solution[1], solution[2], prod);
}
