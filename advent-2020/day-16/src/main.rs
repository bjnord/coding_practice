use day_16::puzzle::Puzzle;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let puzzle = Puzzle::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let errors = puzzle.scanning_error_rate();
    let run_time = start.elapsed() - gen_time;
    println!("Day 16 - Part 1 : {} <=> 28884 expected", errors);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let puzzle = Puzzle::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let departure_product: u64 = puzzle.your_ticket_fields()
        .iter()
        .filter(|f| f.name.contains("departure"))
        .map(|f| f.value as u64)
        .product();
    let run_time = start.elapsed() - gen_time;
    println!("Day 16 - Part 2 : {} <=> 1001849322119 expected", departure_product);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
