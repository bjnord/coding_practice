#![warn(clippy::pedantic)]

use day_04::Passport;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let passports = Passport::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = passports.into_iter().filter(Passport::is_complete).count();
    let run_time = start.elapsed() - gen_time;
    println!("Day 4 - Part 1 : {} <=> 206 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let passports = Passport::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = passports.into_iter().filter(Passport::is_valid).count();
    let run_time = start.elapsed() - gen_time;
    println!("Day 4 - Part 2 : {} <=> 123 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
