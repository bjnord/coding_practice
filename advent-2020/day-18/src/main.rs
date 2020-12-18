use day_18::Equation;
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
    let answer: i64 = equations
        .iter()
        .map(|eq| eq.solve().unwrap())
        .sum();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 6923486965641 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    //let equations = Equation::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
