// the "::{self, Write}" is for the flush() call
// TODO what does this mean / how does this work?
use std::io::{self, Write};

fn main() {
    let mut sum = 0;
    let n_num = loop {
        let x = get_inumber("How many numbers do you want to add? ");
        if x > 1 {
            break x;
        } else {
            println!("Adding requires two or more numbers.");
        }
    };
    for i in 1..(n_num+1) {
        let prompt = format!("Enter number #{}: ", i);
        let n = get_inumber(&prompt[..]);
        sum += n;
    }
    println!("The total is {}.", sum);
}

fn get_inumber(prompt: &str) -> i32 {
    loop {
        print_prompt(prompt);
        let resp = read_response();
        match resp.parse::<i32>() {
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
