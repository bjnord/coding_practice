use day_07::circuit::Circuit;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let circuit = Circuit::new(&input);
    let gen_time = start.elapsed();
    let ans: u16 = 0;
    let run_time = start.elapsed() - gen_time;
    println!("Day 7 - Part 1 : {} <=> 1 expected", ans);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
