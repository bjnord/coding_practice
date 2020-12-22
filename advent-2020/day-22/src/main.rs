use day_22::{Deck, Game};
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut decks = Deck::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let winner = Game::play(&mut decks, false);
    let score = decks[winner - 1].score();
    println!("winner = {}", winner);
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 32413 expected", score);
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
    println!("Day 1 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
