#![warn(clippy::pedantic)]

use day_07::Rules;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let rules = Rules::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = rules.can_contain("shiny gold").len();
    let run_time = start.elapsed() - gen_time;
    println!("Day 7 - Part 1 : {} <=> 172 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let rules = Rules::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = rules.contained_by("shiny gold");
    let run_time = start.elapsed() - gen_time;
    println!("Day 7 - Part 2 : {} <=> 39645 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
