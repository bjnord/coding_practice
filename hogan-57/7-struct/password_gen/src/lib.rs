mod pw_charset;
use pw_charset::PasswordCharset;
use rand::Rng;

pub fn generate(min_len: u32, n_numbers: u32, n_specials: u32) -> String {
    let mut password = String::new();
    let mut letters = PasswordCharset::from_range_incl('a', 'z');
    letters.add_range_incl('A', 'Z');
    let numbers = PasswordCharset::from_range_incl('0', '9');
    let mut specials = PasswordCharset::from_range_incl('!', '/');
    specials.add_range_incl(':', '@');
    specials.add_range_incl('[', '`');
    specials.add_range_incl('{', '~');
    for _ in 0..n_numbers {
        password.push(numbers.random_char());
    }
    for _ in 0..n_specials {
        password.push(specials.random_char());
    }
    while password.len() < min_len as usize {
        password.push(letters.random_char());
    }
    scramble(password)
}

fn scramble(mut password: String) -> String {
    let mut scrambled = String::new();
    let mut rng = rand::thread_rng();
    while !password.is_empty() {
        let i = rng.gen_range(0, password.len());
        let c = password.chars().nth(i).unwrap();
        scrambled.push(c);
        password.replace_range(i..i+1, "");
    }
    scrambled
}

#[cfg(test)]
fn counts(password: String) -> (u32, u32, u32) {
    let (mut a, mut n, mut s) = (0, 0, 0);
    for c in password.chars() {
        if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
            a += 1;
        } else if c >= '0' && c <= '9' {
            n += 1;
        } else {
            s += 1;
        }
    }
    (a, n, s)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn generate_only_letters() {
        let p = generate(8, 0, 0);
        let counts = counts(p);
        assert_eq!(counts.0, 8);
        assert_eq!(counts.1, 0);
        assert_eq!(counts.2, 0);
    }

    #[test]
    fn generate_letters_and_numbers() {
        let p = generate(8, 2, 0);
        let counts = counts(p);
        assert_eq!(counts.0, 6);
        assert_eq!(counts.1, 2);
        assert_eq!(counts.2, 0);
    }

    #[test]
    fn generate_letters_numbers_and_specials() {
        let p = generate(12, 3, 2);
        let counts = counts(p);
        assert_eq!(counts.0, 7);
        assert_eq!(counts.1, 3);
        assert_eq!(counts.2, 2);
    }
}
