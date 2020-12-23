use day_20::image::Image;
use day_20::Tile;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let tiles = Tile::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let answer = Tile::neosolve(&tiles);
    let run_time = start.elapsed() - gen_time;
    println!("Day 20 - Part 1 : {} <=> 11788777383197 expected", answer);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let tiles = Tile::read_from_file("input/example1.txt").unwrap();  // FIXME input.txt
    let gen_time = start.elapsed();
    let image = Image::from_tiles(&tiles).unwrap();
    eprintln!("{}", image);
    image.find_sea_monsters();
    let run_time = start.elapsed() - gen_time;
    println!("Day 20 - Part 2 : {} <=> _ expected", 0);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}
