use day_22::{Deck, Game};
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let decks = Deck::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let mut game = Game::from_decks(0, decks, false);
    game.play();
    let score = game.winner().1;
    let run_time = start.elapsed() - gen_time;
    println!("Day 22 - Part 1 : {} <=> 32413 expected", score);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let decks = Deck::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let mut game = Game::from_decks(1, decks, false);
    game.play();
    let score = game.winner().1;
    let run_time = start.elapsed() - gen_time;
    println!("Day 22 - Part 2 : {} <=> 31596 expected", score);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
