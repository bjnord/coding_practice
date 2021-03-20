/// Problem 33: [Digit cancelling fractions](https://projecteuler.net/problem=33)

use crate::math::IntFraction;

pub struct Problem0033 { }

impl Problem0033 {
    /// Find the denominator of the fraction which is the product of the
    /// four nontrivial "digit cancelable" fractions, when the product is
    /// expressed in lowest common terms.
    #[must_use]
    pub fn solve() -> i64 {
        let nontrivials: Vec<IntFraction> = Self::nontrivials();
        let prod: IntFraction = nontrivials.iter()
            .fold(IntFraction::new(1, 1), |acc, &int_f| acc.mult(int_f));
        // Hey, look!
        if prod.denom.rem_euclid(prod.num) == 0 {
            return prod.denom / prod.num
        }
        panic!("we need a LCM function")
    }

    /// Find the four fractions, less than one in value, and containing two
    /// digits in the numerator and denominator, for which "cancelling
    /// digits" yields an equal fraction. For example, starting with `49/98`
    /// and canceling the `9` digits gives `4/8` which is equal to it.
    ///
    /// (The four _exclude_ "trivial" examples in which the numerator and
    /// denominator are both a multiple of 10.)
    pub fn nontrivials() -> Vec<IntFraction> {
        let mut list: Vec<IntFraction> = Vec::new();
        // `n/d` must be less than 1, so `10/11` is the smallest pair
        for d in 11..100 {
            for n in 10..d {
                let int_f = IntFraction::new(n, d);
                if Self::is_nontrivial(int_f) {
                    list.push(int_f);
                }
            }
        }
        list
    }

    // Is `n/d` a nontrivial example of a "digit cancelable" fraction?
    fn is_nontrivial(int_f: IntFraction) -> bool {
        if int_f.num < 10 || int_f.num > 99 || int_f.denom < 10 || int_f.denom > 99 {
            panic!("must be two-digit numbers");
        }
        let n0 = int_f.num / 10;
        let n1 = int_f.num.rem_euclid(10);
        let d0 = int_f.denom / 10;
        let d1 = int_f.denom.rem_euclid(10);
        if n1 == 0 && d1 == 0 {
            return false;  // trivial
        }
        if n0 == d0 && int_f.equals(IntFraction::new(n1, d1)) {
            return true;
        }
        if n1 == d0 && int_f.equals(IntFraction::new(n0, d1)) {
            return true;
        }
        if n0 == d1 && int_f.equals(IntFraction::new(n1, d0)) {
            return true;
        }
        if n1 == d1 && int_f.equals(IntFraction::new(n0, d0)) {
            return true;
        }
        false
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 33 answer is {}", Self::solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0033::solve();
        assert_eq!(100, answer);
    }

    #[test]
    fn test_nontrivials() {
        let exp: Vec<IntFraction> = vec![
            IntFraction::new(16, 64),
            IntFraction::new(26, 65),
            IntFraction::new(19, 95),
            IntFraction::new(49, 98),
        ];
        assert_eq!(exp, Problem0033::nontrivials());
    }

    #[test]
    fn test_is_nontrivial() {
        let int_f_true = IntFraction::new(49, 98);
        assert_eq!(true, Problem0033::is_nontrivial(int_f_true));
        let int_f_false = IntFraction::new(30, 50);
        assert_eq!(false, Problem0033::is_nontrivial(int_f_false));
    }
}
