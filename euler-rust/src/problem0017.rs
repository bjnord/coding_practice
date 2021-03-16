/// Problem 17: [Number letter counts](https://projecteuler.net/problem=17)

const ONES: [&str; 20] = [
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"
];
const TENS: [&str; 10] = [
    "zero", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"
];

pub struct Problem0017 { }

impl Problem0017 {
    /// Find the number of letters in the written-out numbers from 1 to `n`.
    #[must_use]
    pub fn solve(n: usize) -> usize {
        (1..=n).map(|i| Self::written_letters(i)).sum()
    }

    /// Return the written-out number `n`.
    #[must_use]
    pub fn written(n: usize) -> String {
        match n {
            0..=19 => String::from(ONES[n]),
            20..=99 => {
                let t = n / 10;
                let n0 = n.rem_euclid(10);
                match n0 {
                    0 => String::from(TENS[t]),
                    _ => format!("{}-{}", TENS[t], ONES[n0]),
                }
            },
            100..=999 => {
                let h = n / 100;
                let n0 = n.rem_euclid(100);
                match n0 {
                    0 => format!("{} hundred", ONES[h]),
                    _ => format!("{} hundred and {}", ONES[h], Self::written(n0)),
                }
            },
            1000 => String::from("one thousand"),
            _ => panic!("unsupported"),
        }
    }

    // Return the count of just the letters in the written-out number `n`.
    #[must_use]
    fn written_letters(n: usize) -> usize {
        let s = Self::written(n);
        s.chars().filter(|c| c.is_ascii_alphabetic()).count()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 17 answer is {}", Self::solve(1_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0017::solve(5);
        assert_eq!(19, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0017::solve(1_000);
        assert_eq!(21124, answer);
    }

    #[test]
    fn test_written_ones() {
        assert_eq!("zero", Problem0017::written(0));
        assert_eq!("one", Problem0017::written(1));
        assert_eq!("four", Problem0017::written(4));
        assert_eq!("nine", Problem0017::written(9));
        assert_eq!("ten", Problem0017::written(10));
        assert_eq!("eleven", Problem0017::written(11));
        assert_eq!("fifteen", Problem0017::written(15));
        assert_eq!("eighteen", Problem0017::written(18));
        assert_eq!("nineteen", Problem0017::written(19));
    }

    #[test]
    fn test_written_tens() {
        assert_eq!("twenty", Problem0017::written(20));
        assert_eq!("twenty-one", Problem0017::written(21));
        assert_eq!("twenty-five", Problem0017::written(25));
        assert_eq!("thirty", Problem0017::written(30));
        assert_eq!("thirty-two", Problem0017::written(32));
        assert_eq!("thirty-seven", Problem0017::written(37));
        assert_eq!("forty-six", Problem0017::written(46));
        assert_eq!("fifty-eight", Problem0017::written(58));
        assert_eq!("sixty-four", Problem0017::written(64));
        assert_eq!("seventy", Problem0017::written(70));
        assert_eq!("eighty-three", Problem0017::written(83));
        assert_eq!("ninety-nine", Problem0017::written(99));
    }

    #[test]
    fn test_written_hundreds() {
        assert_eq!("one hundred", Problem0017::written(100));
        assert_eq!("one hundred and sixty-one", Problem0017::written(161));
        assert_eq!("two hundred and eighty-two", Problem0017::written(282));
        assert_eq!("three hundred and sixty-five", Problem0017::written(365));
        assert_eq!("four hundred and eighty-seven", Problem0017::written(487));
        assert_eq!("five hundred and thirty-six", Problem0017::written(536));
        assert_eq!("five hundred and fifty-eight", Problem0017::written(558));
        assert_eq!("six hundred and ninety-four", Problem0017::written(694));
        assert_eq!("seven hundred", Problem0017::written(700));
        assert_eq!("seven hundred and forty", Problem0017::written(740));
        assert_eq!("eight hundred and twenty-three", Problem0017::written(823));
        assert_eq!("nine hundred and seventy-nine", Problem0017::written(979));
    }

    #[test]
    fn test_written_thousands() {
        assert_eq!("one thousand", Problem0017::written(1_000));
    }

    #[test]
    fn test_written_letters() {
        let answer = Problem0017::written_letters(342);
        assert_eq!(23, answer);
    }

    #[test]
    fn test_written_letters_2() {
        let answer = Problem0017::written_letters(115);
        assert_eq!(20, answer);
    }
}
