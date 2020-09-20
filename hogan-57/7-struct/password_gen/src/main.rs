extern crate interact_io;
use interact_io::readln;

fn main() {
    let min_len = readln::read_u32("What's the minimum length? ").unwrap();
    let n_specials = readln::read_u32("How many special characters? ").unwrap();
    let n_numbers = readln::read_u32("How many numbers? ").unwrap();
    println!("Your passwords are:");
    for _ in 0..10 {
        let pw = password_gen::generate(min_len, n_numbers, n_specials);
        println!("{}", pw);
    }
}
