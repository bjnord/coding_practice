use day_12::Ferry;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut ferry = Ferry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    ferry.follow_instructions(0);
    let run_time = start.elapsed() - gen_time;
    println!("Day 11 - Part 1 : {} <=> 1221 expected", ferry.manhattan());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let mut ferry = Ferry::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    ferry.follow_actual_instructions(-1, 10);
    let run_time = start.elapsed() - gen_time;
    println!("Day 11 - Part 2 : {} <=> 59435 expected", ferry.manhattan());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
