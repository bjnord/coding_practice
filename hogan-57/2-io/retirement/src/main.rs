use chrono::{Datelike, Utc};
use std::io::{self, Write};

// TODO "as i32" will silently evaluate to 0 on overflow
//      for airtight Ok/Err handling, see <https://stackoverflow.com/a/28280042/291754>
fn main() {
    let cur_age = get_number("What is your current age? ") as i32;
    let ret_age = get_number("At what age would you like to retire? ") as i32;
    let years = ret_age - cur_age;
    let cur_year = get_cur_year() as i32;
    if years < 0 {
        let ret_year = cur_year + years;
        println!("It's {}, and you could have retired back in {}.", cur_year, ret_year);
    } else if years == 0 {
        println!("It's {}, and you can retire now.", cur_year);
    } else {
        println!("You have {} years left until you can retire.", years);
        let ret_year = cur_year + years;
        println!("It's {}, so you can retire in {}.", cur_year, ret_year);
    }
}

fn get_number(prompt: &str) -> u32 {
    loop {
        print_prompt(prompt);
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

fn get_cur_year() -> u32 {
    let now = Utc::now();
    let (_is_ce, year) = now.year_ce();
    year
}
