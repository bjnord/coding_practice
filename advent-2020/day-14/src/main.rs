use day_14::program_v1::ProgramV1;
use day_14::program_v2::ProgramV2;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut program = ProgramV1::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    program.run();
    let sum = program.memory_sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 14 - Part 1 : {} <=> 6317049172545 expected", sum);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let mut program = ProgramV2::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    program.run();
    let sum = program.memory_sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 14 - Part 2 : {} <=> 3434009980379 expected", sum);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
