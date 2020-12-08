use day_01::{Entry, ENTRY_SUM};
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let solution = Entry::find_solution(&entries, 2, ENTRY_SUM).unwrap();
    let prod = solution.iter().product::<i32>();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 776064 expected", prod);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let solution = Entry::find_solution(&entries, 3, ENTRY_SUM).unwrap();
    let prod = solution.iter().product::<i32>();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> 6964490 expected", prod);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
