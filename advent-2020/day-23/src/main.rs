use day_23::Circle;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

const INPUT: &str = "872495136";

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut circle: Circle = INPUT.parse().unwrap();
    let gen_time = start.elapsed();
    circle.do_moves(100, false);
    let run_time = start.elapsed() - gen_time;
    println!("Day 23 - Part 1 : {} <=> 27865934 expected", circle.state());
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
    println!("Day 23 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
