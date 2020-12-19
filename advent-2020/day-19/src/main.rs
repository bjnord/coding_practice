use day_19::Ruleset;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let ruleset = Ruleset::read_from_file("input/input.txt", false).unwrap();
    let gen_time = start.elapsed();
    let answer = ruleset.match_count();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 198 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let ruleset = Ruleset::read_from_file("input/input.txt", true).unwrap();
    let gen_time = start.elapsed();
    let answer = ruleset.match_count();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> 372 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
