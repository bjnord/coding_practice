#![warn(clippy::pedantic)]

use day_03::Forest;
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
    let dx = 3;
    let dy = 1;
    let trees = trees_on_trajectory("input/input.txt", dy, dx);
    println!("== PART 1 ==");
    println!("will encounter {} trees on trajectory right={} down={} (should be 151)", trees, dx, dy);
}

/// Output solution for part 2.
fn part2() {
}

fn trees_on_trajectory(path: &str, dy: usize, dx: usize) -> usize {
    let forest = Forest::from_input_file(path).unwrap();
    let mut trees = 0;
    let mut x = dx;
    let mut y = dy;
    while y < forest.height() {
        let tree = forest.is_tree_at(y, x);
        if tree {
            trees += 1;
        }
        x += dx;
        y += dy;
    }
    trees
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_trees_on_trajectory() {
        assert_eq!(7, trees_on_trajectory("input/example1.txt", 1, 3));
    }
}
