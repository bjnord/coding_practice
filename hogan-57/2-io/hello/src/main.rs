use std::io::{self, Write};

fn main() {
    let name = get_name();
    let greeting = form_greeting(&name);
    print_greeting(&greeting);
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

fn form_greeting(name: &str) -> String {
    format!("Hello, {}, nice to meet you!", name)
}

fn print_greeting(greeting: &str) {
    println!("{}", greeting);
}
