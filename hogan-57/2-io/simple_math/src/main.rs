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
    loop {
        let prompt = format!("What is the {} number? ", which);
        print_prompt(&prompt[..]);
        let resp = read_response();
        match resp.parse::<u32>() {
            Ok(i) => break i,
            Err(e) => println!("That is not a valid number: {}", e)
        }
    }
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
