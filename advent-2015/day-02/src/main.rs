use day_02::Wrapping;
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
    let packages: Vec<Wrapping> = input
        .lines()
        .map(|line| line.trim().parse::<Wrapping>().unwrap())
        .collect();
    let gen_time = start.elapsed();
    let total_paper = packages.iter().map(Wrapping::paper).sum::<u32>();
    let run_time = start.elapsed() - gen_time;
    println!("Day 2 - Part 1 : {} <=> 1606483 expected", total_paper);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt").unwrap();
    let packages: Vec<Wrapping> = input
        .lines()
        .map(|line| line.trim().parse::<Wrapping>().unwrap())
        .collect();
    let gen_time = start.elapsed();
    let total_ribbon = packages.iter().map(Wrapping::ribbon).sum::<u32>();
    let run_time = start.elapsed() - gen_time;
    println!("Day 2 - Part 2 : {} <=> 3842356 expected", total_ribbon);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
