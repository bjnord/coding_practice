/// Problem 26: [Reciprocal cycles](https://projecteuler.net/problem=26)

use crate::math::Math;
use rug::Float;

#[derive(PartialEq, Eq, PartialOrd, Ord)]
struct RepeatLen {
    len: usize,
    d: u32,
}

pub struct Problem0026 { }

impl Problem0026 {
    /// Find the value of d < `n` for which 1/d contains the longest
    /// recurring cycle in its decimal fraction part, using the given
    /// precision `prec` (bits).
    #[must_use]
    pub fn solve(n: u32, prec: u32) -> u32 {
        (2..n).map(|d| Self::find_replen(d, prec)).max().unwrap().d
    }

    // Find length of the repeating portion of `1/d` at the given precision.
    fn find_replen(d: u32, prec: u32) -> RepeatLen {
        let num = Float::with_val(prec, 1.0);
        let denom = Float::with_val(prec, d);
        let f = num / denom;
        let (_sign, _nonrep, rep, _exp) = Math::decimal_cycle(&f);
        RepeatLen { len: rep.len(), d }
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 26 answer is {}", Self::solve(1_000, 8192))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0026::solve(11, 128);
        assert_eq!(7, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        // FIXME OPTIMIZE takes over a minute to run
        //let answer = Problem0026::solve(1_000, 8192);
        //assert_eq!(983, answer);
        assert_eq!("too", "slow");
    }
}
