extern crate interact_io;
use interact_io::readln;

fn main() {
    let name = readln::read_string("What is your name? ");
    let greeting = form_greeting(&name);
    print_greeting(&greeting);
}

fn form_greeting(name: &str) -> String {
    format!("Hello, {}, nice to meet you!", name)
}

fn print_greeting(greeting: &str) {
    println!("{}", greeting);
}
