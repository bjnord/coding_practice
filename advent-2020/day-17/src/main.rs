use day_17::InfiniteGrid;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut grid = InfiniteGrid::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let n_rounds = 6;
    let mut n_active: usize = 0;
    for i in 0..=n_rounds {
        if i == n_rounds {
            n_active = grid.active_cubes();
            break;
        }
        if i < 0 {
            println!("== ROUND {} EDGE ? ==", i);
            print!("{}", grid);
            println!("====================");
            println!();
        }
        grid = grid.cube_round();
    }
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 317 expected", n_active);
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
