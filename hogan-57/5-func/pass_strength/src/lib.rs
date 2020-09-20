pub struct PasswordCount(u32, u32, u32, bool);

// TODO make this (and PasswordCount) private
//      caller only wants the grade; doesn't care about the details
pub fn password_count(passwd: &str) -> PasswordCount {
    let mut alpha: u32 = 0;
    let mut num: u32 = 0;
    let mut other: u32 = 0;
    let p_ch: Vec<char> = passwd.chars().collect();
    for ch in &p_ch {
        if ch.is_alphabetic() {
            alpha += 1;
        } else if ch.is_digit(10) {
            num += 1;
        }  else {
            other += 1;
        }
    }
    let great8 = passwd.chars().count() >= 8;
    PasswordCount(alpha, num, other, great8)
}

pub fn password_grade(pcount: PasswordCount) -> String {
    // the rules given in the book don't cover all the cases;
    // I'm calling anything less than 8 characters "weak"
    // even if it has letters, numbers, and symbols
    let g = match pcount {
        PasswordCount(0, _, 0, false) => "very weak",
        PasswordCount(_, _, _, false) => "weak",
        PasswordCount(_, _, 0, true) => "strong",
        PasswordCount(_, _, _, true) => "very strong",
    };
    String::from(g)
}

// TODO add tests for `password_count` and `password_grade`
