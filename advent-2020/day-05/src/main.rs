use day_05::BoardingPass;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let passes = BoardingPass::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let max_seat = BoardingPass::max_seat(&passes).unwrap();
    let run_time = start.elapsed() - gen_time;
    println!("Day 5 - Part 1 : {} <=> 848 expected", max_seat);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let passes = BoardingPass::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let empty_seat = BoardingPass::empty_seat(&passes).unwrap();
    let run_time = start.elapsed() - gen_time;
    println!("Day 5 - Part 2 : {} <=> 682 expected", empty_seat);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
