#[macro_use] extern crate scan_fmt;

mod memory;
mod program_v1;

use crate::program_v1::Program;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut program = Program::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    program.run();
    let sum = program.memory_sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 6317049172545 expected", sum);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    //let program = Program::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
