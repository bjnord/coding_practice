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
    let forest = Forest::from_input_file("input/input.txt").unwrap();
    let trees = trees_on_trajectory(&forest, dy, dx);
    println!("== PART 1 ==");
    println!("will encounter {} trees on trajectory right={} down={} (should be 151)", trees, dx, dy);
}

/// Output solution for part 2.
fn part2() {
    let dx = [1, 3, 5, 7, 1];
    let dy = [1, 1, 1, 1, 2];
    println!("== PART 2 ==");
    let forest = Forest::from_input_file("input/input.txt").unwrap();
    let mut prod = 1;
    for i in 0..5 {
        let trees = trees_on_trajectory(&forest, dy[i], dx[i]);
        println!("will encounter {} trees on trajectory right={} down={}", trees, dx[i], dy[i]);
        prod *= trees;
    }
    println!("product of trees is {} (should be 7540141059)", prod);
}

fn trees_on_trajectory(forest: &Forest, dy: usize, dx: usize) -> usize {
    let mut trees = 0;
    let mut x = dx;
    let mut y = dy;
    while y < forest.height() {
        if forest.is_tree_at(y, x) {
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
        let forest = Forest::from_input_file("input/example1.txt").unwrap();
        assert_eq!(2, trees_on_trajectory(&forest, 1, 1));
        assert_eq!(7, trees_on_trajectory(&forest, 1, 3));
        assert_eq!(3, trees_on_trajectory(&forest, 1, 5));
        assert_eq!(4, trees_on_trajectory(&forest, 1, 7));
        assert_eq!(2, trees_on_trajectory(&forest, 2, 1));
    }
}
