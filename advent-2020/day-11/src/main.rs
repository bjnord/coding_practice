use day_11::{FillRules, SeatLayout};
use std::env;
use std::time::Instant;

fn main() {
    let argv: Vec<String> = env::args().collect();
    if argv.len() < 3 {
        part1();
        part2();
    } else {
        match &argv[1][..] {
            "-s" | "--stringent" => dump_rounds(&argv[2], FillRules::Stringent),
            "-t" | "--tolerant" => dump_rounds(&argv[2], FillRules::Tolerant),
            _ => panic!("invalid arguments: {:?}", argv),
        }
    }
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
    let layout = SeatLayout::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let stable_layout = layout.fill_seats_until_stable(FillRules::Tolerant);
    let run_time = start.elapsed() - gen_time;
    println!("Day 11 - Part 2 : {} <=> 2002 expected", stable_layout.occupied_seats());
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

fn dump_rounds(path: &str, rules: FillRules) {
    let layout = SeatLayout::read_from_file(path).unwrap();
    println!("Initial State - Occupied {}\n{}", layout.occupied_seats(), layout);
    for (i, round) in layout.iter(rules).enumerate() {
        println!("Round {} - Occupied {}\n{}", i+1, round.occupied_seats(), round);
    }
}
