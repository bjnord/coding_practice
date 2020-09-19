use password_gen::pass_gen::pw_charset::PasswordCharset;

fn main() {
    let letters = PasswordCharset::from_range_incl('a', 'z');
    println!("there are {} letters", letters.count());
    let a = letters.random_char();
    println!("a random letter is: {}", a);
}
