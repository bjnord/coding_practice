extern crate interact_io;
use interact_io::readln;

fn main() {
    let input = readln::read_string("What is the input string? ");
    let count = input.chars().count();
    println!("{} has {} characters.", input, count);
}
