use day_09::{Entry, XmasList};
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
    let entry = XmasList::find_first_nonsum(&entries, 25).unwrap();
    let run_time = start.elapsed() - gen_time;
    println!("Day 9 - Part 1 : {} <=> 18272118 expected", entry.value());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    //let entries = Entry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 9 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
