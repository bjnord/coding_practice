// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};

struct PasswordCount(u32, u32, u32, bool);

fn main() {
    let passwd = get_input("Enter a password to test: ");
    let pcount = password_count(&passwd[..]);
    let grade = password_grade(pcount);
    println!("The password '{}' is a {} password.", passwd, grade);
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

fn password_count(passwd: &str) -> PasswordCount {
    let mut alpha: u32 = 0;
    let mut num: u32 = 0;
    let mut other: u32 = 0;
    let p_ch: Vec<char> = passwd.chars().collect();
    for ch in &p_ch {
        if ch.is_alphabetic() {
            alpha += 1;
        } else if ch.is_digit(10) {
            num += 1;
        }  else {
            other += 1;
        }
    }
    let great8 = passwd.chars().count() >= 8;
    PasswordCount(alpha, num, other, great8)
}

fn password_grade(pcount: PasswordCount) -> String {
    // the rules given in the book don't cover all the cases;
    // I'm calling anything less than 8 characters "weak"
    // even if it has letters, numbers, and symbols
    let g = match pcount {
        PasswordCount(0, _, 0, false) => { "very weak" },
        PasswordCount(_, _, _, false) => { "weak" },
        PasswordCount(_, _, 0, true) => { "strong" },
        PasswordCount(_, _, _, true) => { "very strong" },
    };
    String::from(g)
}
