/// Problem 33: [Digit cancelling fractions](https://projecteuler.net/problem=33)

pub struct Problem0033 { }

impl Problem0033 {
    /// Find the denominator of the fraction which is the product of the
    /// four nontrivial "digit cancelable" fractions, when the product is
    /// expressed in lowest common terms.
    #[must_use]
    pub fn solve() -> i64 {
        let nt: Vec<(i64, i64)> = Self::nontrivials();
        let n = nt[0].0 * nt[1].0 * nt[2].0 * nt[3].0;
        let d = nt[0].1 * nt[1].1 * nt[2].1 * nt[3].1;
        // Hey, look!
        if d.rem_euclid(n) == 0 {
            return d/n
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
    pub fn nontrivials() -> Vec<(i64, i64)> {
        let mut list: Vec<(i64, i64)> = Vec::new();
        // `n/d` must be less than 1, so `10/11` is the smallest pair
        for d in 11..100 {
            for n in 10..d {
                if Self::is_nontrivial(n, d) {
                    list.push((n, d));
                }
            }
        }
        list
    }

    // Is `n/d` a nontrivial example of a "digit cancelable" fraction?
    fn is_nontrivial(n: i64, d: i64) -> bool {
        if n < 10 || n > 99 || d < 10 || d > 99 {
            panic!("must be two-digit numbers");
        }
        let n0 = n / 10;
        let n1 = n.rem_euclid(10);
        let d0 = d / 10;
        let d1 = d.rem_euclid(10);
        if n1 == 0 && d1 == 0 {
            return false;  // trivial
        }
        if n0 == d0 && Self::canceled_equals(n, d, n1, d1) {
            return true;
        }
        if n1 == d0 && Self::canceled_equals(n, d, n0, d1) {
            return true;
        }
        if n0 == d1 && Self::canceled_equals(n, d, n1, d0) {
            return true;
        }
        if n1 == d1 && Self::canceled_equals(n, d, n0, d0) {
            return true;
        }
        false
    }

    // Is `n/d` equal to `n0/d0`?
    fn canceled_equals(n: i64, d: i64, n0: i64, d0: i64) -> bool {
        let first = n as f64 / d as f64;
        let second = n0 as f64 / d0 as f64;
        (first - second).abs() < 0.000_000_000_001
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
        assert_eq!(vec![(16, 64), (26, 65), (19, 95), (49, 98)], Problem0033::nontrivials());
    }

    #[test]
    fn test_is_nontrivial() {
        assert_eq!(true, Problem0033::is_nontrivial(49, 98));
        assert_eq!(false, Problem0033::is_nontrivial(30, 50));
    }

    #[test]
    fn test_canceled_equals() {
        assert_eq!(true, Problem0033::canceled_equals(49, 98, 4, 8));
        assert_eq!(false, Problem0033::canceled_equals(47, 78, 4, 8));
    }
}
