/// Problem 14: [Longest Collatz sequence](https://projecteuler.net/problem=14)

pub struct Problem0014 { }

impl Problem0014 {
    /// Find the starting number under `n` which produces the longest
    /// Collatz sequence.
    #[must_use]
    pub fn solve(n: u64) -> u64 {
        let mut max_len: usize = 0;
        let mut max: u64 = 0;
        for i in 2..n {
            let seq = Self::collatz(i);
            if seq.len() > max_len {
                max = i;
                max_len = seq.len();
            }
        }
        max
    }

    /// Compute the Collatz sequence starting at `n`.
    #[must_use]
    pub fn collatz(n: u64) -> Vec<u64> {
        let mut seq: Vec<u64> = vec![n];
        let mut i = n;
        while i != 1 {
            if i & 0x1 == 0x0 {
                i /= 2;
            } else {
                i = 3*i + 1;
            }
            seq.push(i);
        }
        seq
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 14 answer is {}", Self::solve(1_000_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_collatz_example() {
        let seq = Problem0014::collatz(13);
        assert_eq!(vec![13, 40, 20, 10, 5, 16, 8, 4, 2, 1], seq);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0014::solve(1_000_000);
        assert_eq!(837799, answer);
    }
}
