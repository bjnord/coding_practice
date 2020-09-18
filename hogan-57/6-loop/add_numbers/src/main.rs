use std::io::{self, Write};

fn main() {
    let n_num = get_n_numbers();
    let sum = add_numbers(n_num);
    println!("The total is {}.", sum);
}

fn get_n_numbers() -> u32 {
    loop {
        let x = get_inumber("How many numbers do you want to add? ");
        if x > 1 {
            break x as u32;
        } else {
            println!("Adding requires two or more numbers.");
        }
    }
}

fn add_numbers(n_num: u32) -> i32 {
    let mut sum: i32 = 0;
    for i in 1..(n_num+1) {
        let prompt = format!("Enter number #{}: ", i);
        let n = get_inumber(&prompt);
        sum += n;
    }
    sum
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
