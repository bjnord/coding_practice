use day_18::equation::Equation;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let equations = Equation::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let answer: i64 = equations.iter().map(|eq| eq.solve().unwrap()).sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 18 - Part 1 : {} <=> 6923486965641 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let equations = Equation::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let answer: i64 = equations
        .iter()
        .map(|eq| eq.solve_advanced_math().unwrap())
        .sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 18 - Part 2 : {} <=> 70722650566361 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
