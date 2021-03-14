/// Problem 2: [Even Fibonacci numbers](https://projecteuler.net/problem=2)

pub struct Problem0002 { }

impl Problem0002 {
    /// Find the sum of the even terms in the Fibonacci sequence whose
    /// values do not exceed the given value.
    #[must_use]
    pub fn solve(limit: u32) -> u32 {
        let mut a = 1;
        let mut b = 2;
        let mut sum = 2;
        loop {
            let c = a + b;
            a = b;
            b = c;
            if c > limit {
                break;
            }
            if c & 0x1 == 0x0 {
                sum += c;
            }
        }
        sum
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 2 answer is {}", Self::solve(4_000_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0002::solve(4_000_000);
        assert_eq!(4613732, answer);
    }
}
