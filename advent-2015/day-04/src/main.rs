use day_04::AdventCoin;
use std::fs;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt")
        .unwrap()
        .trim()
        .to_string();
    let coin = AdventCoin::new(&input);
    let gen_time = start.elapsed();
    let number = coin.number(5);
    let run_time = start.elapsed() - gen_time;
    println!("Day 4 - Part 1 : {} <=> 282749 expected", number);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let input: String = fs::read_to_string("private/input.txt")
        .unwrap()
        .trim()
        .to_string();
    let coin = AdventCoin::new(&input);
    let gen_time = start.elapsed();
    let number = coin.number(6);
    let run_time = start.elapsed() - gen_time;
    println!("Day 4 - Part 2 : {} <=> 9962624 expected", number);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
