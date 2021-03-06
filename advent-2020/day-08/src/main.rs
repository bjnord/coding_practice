use day_08::{Program, HaltType};
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let program = Program::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let acc = match program.run_until_halt(usize::MAX) {
        HaltType::Looped { acc } => acc,
        _ => panic!("program did not loop"),
    };
    let run_time = start.elapsed() - gen_time;
    println!("Day 8 - Part 1 : {} <=> 2058 expected", acc);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let program = Program::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let acc = program.find_pc_flip_acc().unwrap();
    let run_time = start.elapsed() - gen_time;
    println!("Day 8 - Part 2 : {} <=> 1000 expected", acc);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
