// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};
use std::iter::FromIterator;

fn main() {
    let first = get_input("Enter the first string: ");
    let second = get_input("Enter the second string: ");
    if first == second {
        println!("{} and {} are the same string.", first, second);
    } else if are_anagrams(&first[..], &second[..]) {
        println!("{} and {} are anagrams.", first, second);
    } else {
        println!("{} and {} are not anagrams.", first, second);
    }
}

fn get_input(prompt: &str) -> String {
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

fn are_anagrams(a: &str, b: &str) -> bool {
    let a_sorted = sort_chars(a);
    let b_sorted = sort_chars(b);
    a_sorted == b_sorted
}

fn sort_chars(s: &str) -> String {
    let mut s_ch: Vec<char> = s.chars().collect();
    s_ch.sort();
    // NOTE this is a way to "inspect" a compound object:
    //println!("test{:?}", s_ch);
    String::from_iter(s_ch)
}
