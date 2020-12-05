#![warn(clippy::pedantic)]

use day_04::Passport;
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
    let passports = Passport::read_passports("input/input.txt").unwrap();
    let count = passports.into_iter().filter(Passport::is_complete).count();
    println!("== PART 1 ==");
    println!("{} passports are complete (should be 206)", count);
}

/// Output solution for part 2.
fn part2() {
    let passports = Passport::read_passports("input/input.txt").unwrap();
    let count = passports.into_iter().filter(Passport::is_valid).count();
    println!("== PART 2 ==");
    println!("{} passports are valid (should be 123)", count);
}
