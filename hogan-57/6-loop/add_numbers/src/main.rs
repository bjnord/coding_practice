extern crate interact_io;
use interact_io::readln;

fn main() {
    let n_num = readln::read_u32("How many numbers do you want to add? ");
    if n_num < 2 {
        println!("Adding requires two or more numbers.");
    } else {
        let sum = add_numbers(n_num);
        println!("The total is {}.", sum);
    }
}

fn add_numbers(n_num: u32) -> f64 {
    let mut sum: f64 = 0.0;
    for i in 1..(n_num+1) {
        let prompt = format!("Enter number #{}: ", i);
        let n = readln::read_f64(&prompt);
        sum += n;
    }
    sum
}
