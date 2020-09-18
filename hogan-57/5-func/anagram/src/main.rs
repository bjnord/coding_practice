extern crate interact_io;
use interact_io::readln;
use std::iter::FromIterator;

fn main() {
    let first = readln::read_string("Enter the first string: ");
    let second = readln::read_string("Enter the second string: ");
    if first == second {
        println!("{} and {} are the same string.", first, second);
    } else if are_anagrams(&first, &second) {
        println!("{} and {} are anagrams.", first, second);
    } else {
        println!("{} and {} are not anagrams.", first, second);
    }
}

fn are_anagrams(a: &str, b: &str) -> bool {
    let a_sorted = sort_chars(a);
    let b_sorted = sort_chars(b);
    a_sorted == b_sorted
}

fn sort_chars(s: &str) -> String {
    let mut s_ch: Vec<char> = s.chars().collect();
    s_ch.sort();
    String::from_iter(s_ch)
}
