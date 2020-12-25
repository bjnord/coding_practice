use day_25::Device;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let devices = Device::read_from_file("input/input.txt").unwrap();
    for device in devices {
        eprintln!("{}", device);
    }
    let gen_time = start.elapsed();
    //...
    let run_time = start.elapsed() - gen_time;
    println!("Day 25 - Part 1 : {} <=> _ expected", 0);
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
    println!("Day 25 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
