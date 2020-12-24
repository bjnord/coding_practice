use day_24::Floor;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut floor = Floor::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    floor.set_initial_tiles();
    let answer = floor.n_black();
    let run_time = start.elapsed() - gen_time;
    println!("Day 24 - Part 1 : {} <=> 459 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let mut floor = Floor::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    floor.set_initial_tiles();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 24 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
