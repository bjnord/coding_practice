use day_13::BusSchedule;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let schedule = BusSchedule::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let (bus_id, earliest_depart) = schedule.next_bus();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 2298 expected", bus_id * earliest_depart);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let schedule = BusSchedule::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let answer = schedule.earliest_staggered_time();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> 783685719679632 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
