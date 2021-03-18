/// Problem 26: [Reciprocal cycles](https://projecteuler.net/problem=26)

use crate::math::Math;
use rug::Float;

pub struct Problem0026 { }

impl Problem0026 {
    /// Find the value of d < `n` for which 1/d contains the longest
    /// recurring cycle in its decimal fraction part.
    #[must_use]
    pub fn solve(n: u32) -> u32 {
        let mut max_cycle: usize = 0;
        let mut max_d: u32 = 0;
        // for faster `cargo test` only use big-precision for real problem
        let prec: u32 = match n > 11 {
            true => 8192,
            false => 128,
        };
        for d in 2..n {
            let num = Float::with_val(prec, 1.0);
            let denom = Float::with_val(prec, d);
            let f = num / denom;
            let (_sign, _nonrep, rep, _exp) = Math::decimal_cycle(&f);
            //eprintln!("for d={} rep='{}' (len={})", d, rep, rep.len());
            if rep.len() <= max_cycle {
                //eprintln!("  ...shorter than previous max_cycle={}", max_cycle);
                continue;
            }
            //eprintln!("  ...longer than previous max_cycle={}", max_cycle);
            max_cycle = rep.len();
            max_d = d;
        }
        max_d
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 26 answer is {}", Self::solve(1_000))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0026::solve(11);
        assert_eq!(7, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        // FIXME OPTIMIZE takes over a minute to run
        //let answer = Problem0026::solve(1_000);
        //assert_eq!(983, answer);
        assert_eq!("too", "slow");
    }
}
