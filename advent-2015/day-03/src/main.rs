use day_03::Instructions;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let instructions = input.parse::<Instructions>().unwrap();
    let gen_time = start.elapsed();
    let n_houses = instructions.n_present_houses();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 2592 expected", n_houses);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
