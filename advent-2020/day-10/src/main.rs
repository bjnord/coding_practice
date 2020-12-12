use day_10::AdapterSet;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let adapter_set = AdapterSet::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let (one, three) = adapter_set.adapter_usage();
    let run_time = start.elapsed() - gen_time;
    println!("Day 10 - Part 1 : {} <=> 1625 expected", one * three);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let adapter_set = AdapterSet::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let arrangements = adapter_set.adapter_arrangements();
    let run_time = start.elapsed() - gen_time;
    println!("Day 10 - Part 2 : {} <=> 3100448333024 expected", arrangements);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
