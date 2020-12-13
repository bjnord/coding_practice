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
    println!("Day 1 - Part 2 : {} <=> _ expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Example from [this page at the Brilliant wiki](https://brilliant.org/wiki/chinese-remainder-theorem/)
/// solved by hand
#[allow(dead_code)]
fn solve_brilliant() {
    // 6 (mod 7)  ->  x = 7j + 6
    let mut this_modu: u64;
    let mut this_rem: u64;
    let mut next_modu: u64 = 7;
    let mut next_rem: u64 = 6;
    let mut next_mult: u64;
    let mut next_add: u64;

    next_mult = next_modu;
    next_add = next_rem;

    this_modu = next_modu;
    this_rem = next_rem;
    next_modu = 5;
    next_rem = 4;
    let mut sol_rem = BusSchedule::solve_congruence(next_mult, next_add, next_rem, next_modu);
    println!("brill 1+2  j={} mod={}", sol_rem, next_modu);
    // 4 (mod 5)  ->  j = 5k + 4
    //                x = 7(5k + 4) + 6
    //                x = 35k + 34
    let tuple = BusSchedule::substitute_congruence(next_modu, sol_rem, next_mult, next_add);
    next_mult = tuple.0;
    next_add = tuple.1;
    println!("           this=(m{}, r{}) next=(m{}, a{})", this_modu, this_rem, next_mult, next_add);

    this_modu = next_modu;
    this_rem = next_rem;
    next_modu = 3;
    next_rem = 1;
    sol_rem = BusSchedule::solve_congruence(next_mult, next_add, next_rem, next_modu);
    println!("brill 3    k={} mod={}", sol_rem, next_modu);
    // 0 (mod 3)  ->  k = 3l + 0
    //                x = 35(3l + 0) + 34
    //                x = 105l + 34
    let tuple = BusSchedule::substitute_congruence(next_modu, sol_rem, next_mult, next_add);
    next_mult = tuple.0;
    next_add = tuple.1;
    println!("           this=(m{}, r{}) next=(m{}, a{})", this_modu, this_rem, next_mult, next_add);

    // solution: x == 34 (mod 105)
    println!("solution   m{} - r{} = {}", next_mult, next_add, next_mult - next_add);
}

/// Example from [this page at the Brilliant wiki](https://brilliant.org/wiki/chinese-remainder-theorem/)
/// but solved with our class
#[allow(dead_code)]
fn solve_brilliant_2() {
    let schedule: BusSchedule = "0\nx,3,x,x,5,x,7\n".parse().unwrap();
    let answer = schedule.earliest_staggered_time();
    println!("solution   {}", answer);
}
