use rand::Rng;
// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};

const ANSWERS: &'static [&'static str] = &["Yes", "No", "Maybe", "Ask again later"];

fn main() {
    let _question = read_input("What's your question? ");
    let answer = pick_answer(4);
    println!("{}.", ANSWERS[answer]);
}

fn read_input(prompt: &str) -> String {
    print_prompt(prompt);
    read_response()
}

fn print_prompt(prompt: &str) {
    print!("{}", prompt);
    io::stdout().flush()
        .expect("Failed to flush");
}

fn read_response() -> String {
    let mut input = String::new();
    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line");
    String::from(input.trim())
}

fn pick_answer(n: usize) -> usize {
    let mut rng = rand::thread_rng();
    rng.gen_range(0, n)
}
