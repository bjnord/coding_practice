use std::time::Instant;

fn main() {
    part1();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    //
    let gen_time = start.elapsed();
    //
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 1 expected", 1);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
