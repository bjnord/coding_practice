mod pw_charset;
use pw_charset::PasswordCharset;

pub fn generate(_min_len: u32, _specials: u32, _numbers: u32) -> String {
    let letters = PasswordCharset::from_range_incl('a', 'z');
    println!("there are {} letters", letters.count());
    let a = letters.random_char();
    println!("a random letter is: {}", a);
    let numbers = PasswordCharset::from_range_incl('0', '9');
    println!("there are {} numbers", numbers.count());
    let a = numbers.random_char();
    println!("a random number is: {}", a);
    String::from("TODO")
}
