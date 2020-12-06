#![warn(clippy::pedantic)]

use day_03::Forest;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let forest = Forest::from_input_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let trees = trees_on_trajectory(&forest, 1, 3);
    let run_time = start.elapsed() - gen_time;
    println!("Day 3 - Part 1 : {} <=> 151 expected", trees);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let forest = Forest::from_input_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let dx = [1, 3, 5, 7, 1];
    let dy = [1, 1, 1, 1, 2];
    let mut prod = 1;
    for i in 0..5 {
        let trees = trees_on_trajectory(&forest, dy[i], dx[i]);
        //eprintln!("will encounter {} trees on trajectory right={} down={}", trees, dx[i], dy[i]);
        prod *= trees;
    }
    let run_time = start.elapsed() - gen_time;
    println!("Day 3 - Part 2 : {} <=> 7540141059 expected", prod);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
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
