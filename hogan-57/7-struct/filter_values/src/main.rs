extern crate interact_io;
use interact_io::readln;

fn main() {
    let line = readln::read_string("Enter a list of numbers, separated by spaces: ");
    // "The iterator returned will return string slices that are sub-slices of the original string slice, separated by any amount of whitespace."
    let token_iter: std::str::SplitWhitespace = line.split_whitespace();
    let numbers: Vec<i32> = token_iter.map(|s| s.parse().unwrap()).collect();
    let evens: Vec<i32> = numbers.into_iter().filter(|n| n & 0x1 == 0x0).collect();
    let evens: Vec<String> = evens.into_iter().map(|n| format!("{}", n)).collect();
    println!("The even numbers are {}.", evens.join(" "));
}
