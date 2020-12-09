use day_09::{Entry, XmasList};
use std::time::Instant;

fn main() {
    let invalid = part1();
    part2(&invalid);
}

/// Output solution for part 1.
fn part1() -> Entry {
    let start = Instant::now();
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let entry = XmasList::find_first_nonsum(&entries, 25).unwrap();
    let run_time = start.elapsed() - gen_time;
    println!("Day 9 - Part 1 : {} <=> 18272118 expected", entry.value());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
    entry
}

/// Output solution for part 2.
fn part2(invalid: &Entry) {
    let start = Instant::now();
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let sum = Entry::find_sum(&entries, invalid).unwrap();
    let run_time = start.elapsed() - gen_time;
    println!("Day 9 - Part 2 : {} <=> 2186361 expected", sum);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
