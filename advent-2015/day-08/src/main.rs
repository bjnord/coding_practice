use day_08::QuotedString;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let strings: Vec<QuotedString> = input
        .lines()
        .map(|line| line.trim().parse::<QuotedString>().unwrap())
        .collect();
    let gen_time = start.elapsed();
    let total_overhead: usize = strings.iter().map(QuotedString::overhead).sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 8 - Part 1 : {} <=> 1350", total_overhead);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
