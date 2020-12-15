use day_15::Game;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let numbers: Vec<u32> = fs::read_to_string("input/input.txt").unwrap()
        .trim()
        .split(',')
        .map(|n| n.parse().unwrap())
        .collect();
    let gen_time = start.elapsed();
    let solution = Game::play(&numbers, 2020);
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 1009 expected", solution);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    //let entries = Entry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
