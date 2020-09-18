extern crate interact_io;
use interact_io::readln;
use rand::Rng;

const ANSWERS: &'static [&'static str] = &["Yes", "No", "Maybe", "Ask again later"];

fn main() {
    let _question = readln::read_string("What's your question? ");
    let answer = pick_answer(4);
    println!("{}.", ANSWERS[answer]);
}

fn pick_answer(n: usize) -> usize {
    let mut rng = rand::thread_rng();
    rng.gen_range(0, n)
}
