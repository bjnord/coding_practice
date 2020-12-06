#![warn(clippy::pedantic)]

use day_06::Group;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let groups = Group::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count: usize = groups.iter().map(Group::yes_answers).sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 6 - Part 1 : {} <=> 6742 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    // TODO
    let gen_time = start.elapsed();
    let ans = 0;  // TODO
    let run_time = start.elapsed() - gen_time;
    println!("Day 6 - Part 2 : {} <=> _ expected", ans);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
