use day_02::Wrapping;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let packages: Vec<Wrapping> = input
        .lines()
        .map(|line| line.trim().parse::<Wrapping>().unwrap())
        .collect();
    let gen_time = start.elapsed();
    let total_area = packages.iter().map(Wrapping::area).sum::<u32>();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 1606483 expected", total_area);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
