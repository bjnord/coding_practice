// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};

fn main() {
    let name = get_name();
    let greeting = form_greeting(name);
    print_greeting(greeting);
}

fn get_name() -> String {
    print_prompt("What is your name? ");
    read_response()
}

fn print_prompt(prompt: &str) {
    print!("{}", prompt);
    io::stdout().flush()
        .expect("Failed to flush");
}

fn read_response() -> String {
    let mut name = String::new();
    io::stdin()
        .read_line(&mut name)
        .expect("Failed to read line");
    String::from(name.trim())
}

fn form_greeting(name: String) -> String {
    let g = format!("Hello, {}, nice to meet you!", name);
    String::from(g)
}

fn print_greeting(greeting: String) {
    println!("{}", greeting);
}
