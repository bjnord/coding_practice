use day_06::{Grid, Instruction};
use std::fs;
use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let instructions: Vec<Instruction> = input
        .lines()
        .map(|line| line.trim().parse::<Instruction>().unwrap())
        .collect();
    let grid = Grid::new(&instructions);
    let gen_time = start.elapsed();
    let run_time = start.elapsed() - gen_time;
    println!("Day 6 - Part 1 : {} <=> 400410 expected", grid.len());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
