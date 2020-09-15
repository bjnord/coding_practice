// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};

fn main() {
    let a = get_number("first");
    let b = get_number("second");
    println!("{} + {} = {}", a, b, a + b);
    println!("{} - {} = {}", a, b, a - b);
    println!("{} * {} = {}", a, b, a * b);
    println!("{} / {} = {}", a, b, a / b);
}

fn get_number(which: &str) -> u32 {
    let prompt = format!("What is the {} number? ", which);
    print_prompt(&prompt[..]);
    let resp = read_response();
    let n: u32 = resp
        .parse()
        .expect("Not a valid number");
    n
}

fn print_prompt(prompt: &str) {
    print!("{}", prompt);
    io::stdout()
        .flush()
        .expect("Failed to flush");
}

fn read_response() -> String {
    let mut input = String::new();
    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line");
    String::from(input.trim())
}
