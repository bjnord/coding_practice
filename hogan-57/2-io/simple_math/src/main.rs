extern crate interact_io;
use interact_io::readln;

fn main() {
    let a = readln::read_f64("What is the first number? ").unwrap();
    let b = readln::read_f64("What is the second number? ").unwrap();
    println!("{} + {} = {}", a, b, a + b);
    println!("{} - {} = {}", a, b, a - b);
    println!("{} * {} = {}", a, b, a * b);
    println!("{} / {} = {}", a, b, a / b);
}
