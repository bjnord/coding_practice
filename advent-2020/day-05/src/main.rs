#![warn(clippy::pedantic)]

use day_05::BoardingPass;
use std::time::Instant;

fn main() {
    let start = Instant::now();
    part1();
    let duration = start.elapsed();
    eprintln!("Finished after {:?}", duration);
}

/// Output solution for part 1.
fn part1() {
    let passes = BoardingPass::read_from_file("input/input.txt").unwrap();
    let max_seat = max_seat(passes).unwrap();
    println!("== PART 1 ==");
    println!("highest seat ID is {} (should be 848)", max_seat);
}

fn max_seat(passes: Vec<BoardingPass>) -> Option<usize> {
    passes.iter().map(BoardingPass::seat).max()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_max_seat() {
        let passes = BoardingPass::read_from_file("input/example1.txt").unwrap();
        assert_eq!(Some(820), max_seat(passes));
    }

    #[test]
    fn test_max_seat_empty_list() {
        let passes: Vec<BoardingPass> = vec![];
        assert_eq!(None, max_seat(passes));
    }
}
