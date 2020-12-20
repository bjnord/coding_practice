use day_17::{InfiniteGrid, N_ROUNDS};
use std::time::Instant;

const DUMP_N_ROUNDS: usize = 0;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let grid = InfiniteGrid::read_from_file("input/input.txt", 3).unwrap();
    let gen_time = start.elapsed();
    dump_round(0, &grid);  // initial state
    let mut n_active: usize = 0;
    for (i, g) in grid.iter().enumerate() {
        dump_round(i + 1, &g);
        if i + 1 >= N_ROUNDS {
            n_active = g.active_cubes();
            break;
        }
    }
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 317 expected", n_active);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let grid = InfiniteGrid::read_from_file("input/input.txt", 4).unwrap();
    let gen_time = start.elapsed();
    dump_round(0, &grid);  // initial state
    let mut n_active: usize = 0;
    for (i, g) in grid.iter().enumerate() {
        dump_round(i + 1, &g);
        if i + 1 >= N_ROUNDS {
            n_active = g.active_cubes();
            break;
        }
    }
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> 1692 expected", n_active);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

#[allow(clippy::absurd_extreme_comparisons)]
fn dump_round(i: usize, grid: &InfiniteGrid) {
    if DUMP_N_ROUNDS > 0 && i <= DUMP_N_ROUNDS {
        println!("== ROUND {} EDGE {} ==", i, grid.edge());
        print!("{}", grid);
        println!("====================");
        println!();
    }
}
