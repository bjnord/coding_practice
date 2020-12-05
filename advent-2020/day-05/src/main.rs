#![warn(clippy::pedantic)]

use day_05::BoardingPass;
use itertools::Itertools;
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
    let max_seat = max_seat(&passes).unwrap();
    println!("== PART 1 ==");
    println!("highest seat ID is {} (should be 848)", max_seat);
}

/// Find the highest seat ID on any boarding pass.
fn max_seat(passes: &[BoardingPass]) -> Option<usize> {
    passes.iter().map(BoardingPass::seat).max()
}

/// Output solution for part 2.
fn part2() {
    let passes = BoardingPass::read_from_file("input/input.txt").unwrap();
    let empty_seat = empty_seat(&passes).unwrap();
    println!("== PART 2 ==");
    println!("empty seat ID is {} (should be 682)", empty_seat);
}

/// Find the seat ID with no boarding pass.
fn empty_seat(passes: &[BoardingPass]) -> Option<usize> {
    let mut i = passes.iter().sorted_by_key(|p| p.seat());
    let mut last_seat = i.next().unwrap().seat();
    for pass in i {
        let seat = pass.seat();
        if seat <= last_seat {
            panic!("sort failure");
        }
        if seat > last_seat + 1 {
            return Some(last_seat + 1);
        }
        last_seat = seat;
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_max_seat() {
        let passes = BoardingPass::read_from_file("input/example1.txt").unwrap();
        assert_eq!(Some(820), max_seat(&passes));
    }

    #[test]
    fn test_max_seat_empty_list() {
        let passes: Vec<BoardingPass> = vec![];
        assert_eq!(None, max_seat(&passes));
    }

    #[test]
    fn test_empty_seat() {
        // this file (not in order) has:
        // - row 0: empty
        // - row 1: full
        // - row 2: one empty seat in column 3
        // - row 3: full
        let passes = BoardingPass::read_from_file("input/example2.txt").unwrap();
        assert_eq!(Some(2 * 8 + 3), empty_seat(&passes));
    }
}
