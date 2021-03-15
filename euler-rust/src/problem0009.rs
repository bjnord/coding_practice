/// Problem 9: [Special Pythagorean triplet](https://projecteuler.net/problem=9)

pub struct Problem0009 { }

impl Problem0009 {
    /// Find the product `a * b * c` for a Pythagorean triplet for which
    /// `a < b < c` and `a + b + c = n`.
    #[must_use]
    pub fn solve(n: u64) -> u64 {
        for a in 1..=((n-1-2)/3) {
            for b in (a+1)..=((n-a-1)/2) {
                let c = n - a - b;
                if Self::is_pythagorean(a, b, c) {
                    return a * b * c;
                }
            }
        }
        0
    }

    fn is_pythagorean(a: u64, b: u64, c: u64) -> bool {
        a * a + b * b == c * c
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 9 answer is {}", Self::solve(1000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0009::solve(3 + 4 + 5);
        assert_eq!(3 * 4 * 5, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0009::solve(1000);
        assert_eq!(31875000, answer);
    }
}
