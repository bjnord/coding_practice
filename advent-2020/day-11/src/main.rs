use day_11::{FillRules, SeatLayout};
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let layout = SeatLayout::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let stable_layout = layout.fill_seats_until_stable(FillRules::Stringent);
    let run_time = start.elapsed() - gen_time;
    println!("Day 11 - Part 1 : {} <=> 2263 expected", stable_layout.occupied_seats());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    //let layout = SeatLayout::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 11 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
