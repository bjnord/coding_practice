use day_25::Device;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let mut devices = Device::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    devices[0].set_loop_size();
    let public_key_1 = devices[1].public_key();
    let key = devices[0].encryption_key(public_key_1);
    let run_time = start.elapsed() - gen_time;
    println!("Day 25 - Part 1 : {} <=> 18293391 expected", key);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let gen_time = start.elapsed();
    let run_time = start.elapsed() - gen_time;
    println!("Day 25 - Part 2 : {} <=> FREE expected", "FREE");
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
