#![warn(clippy::pedantic)]

use day_05::BoardingPass;
use std::time::Instant;

fn main() {
    let start = Instant::now();
    part1();
    part2();
    let duration = start.elapsed();
    eprintln!("Finished after {:?}", duration);
}

/// Output solution for part 1.
fn part1() {
    let passes = BoardingPass::read_from_file("input/input.txt").unwrap();
    let max_seat = BoardingPass::max_seat(&passes).unwrap();
    println!("== PART 1 ==");
    println!("highest seat ID is {} (should be 848)", max_seat);
}

/// Output solution for part 2.
fn part2() {
    let passes = BoardingPass::read_from_file("input/input.txt").unwrap();
    let empty_seat = BoardingPass::empty_seat(passes).unwrap();
    println!("== PART 2 ==");
    println!("empty seat ID is {} (should be 682)", empty_seat);
}
