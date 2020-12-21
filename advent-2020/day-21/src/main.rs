use day_21::FoodList;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let food_list = FoodList::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = food_list.non_allergen_ingredient_count();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 2542 expected", count);
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
