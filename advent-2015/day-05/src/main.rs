use day_05::SantaString;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let santa_strings: Vec<SantaString> = input
        .lines()
        .map(|line| line.trim().parse::<SantaString>().unwrap())
        .collect();
    let gen_time = start.elapsed();
    let n_nice: u32 = santa_strings.iter().map(|ss| u32::from(ss.is_nice())).sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 5 - Part 1 : {} <=> 258 expected", n_nice);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
