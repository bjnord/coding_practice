use day_01::Instructions;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let instructions = input.parse::<Instructions>().unwrap();
    let gen_time = start.elapsed();
    let floor = instructions.floor();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 74 expected", floor);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let instructions = input.parse::<Instructions>().unwrap();
    let gen_time = start.elapsed();
    let basement = instructions.basement();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> 1795 expected", basement);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
