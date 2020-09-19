use rand::Rng;

pub struct PasswordCharset {
    charset: String,
}

impl PasswordCharset {
    pub fn from_range_incl(start: char, end: char) -> PasswordCharset {
        let mut charset = String::new();
        for c in start..end {
            charset.push(c);
        }
        charset.push(end);
        PasswordCharset {charset}
    }

    pub fn count(&self) -> usize {
        self.charset.len()
    }

    pub fn random_char(&self) -> char {
        let mut rng = rand::thread_rng();
        let i = rng.gen_range(0, self.count());
        self.charset.chars().nth(i).unwrap()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn construct_from_range_incl() {
        let pc = PasswordCharset::from_range_incl('a', 'f');
        assert_eq!("abcdef", &pc.charset);
    }

    #[test]
    fn get_random_char() {
        let pc = PasswordCharset::from_range_incl('a', 'f');
        let c = pc.random_char();
        assert!(c >= 'a');
        assert!(c <= 'f');
    }
}
