/// Problem 26: [Reciprocal cycles](https://projecteuler.net/problem=26)

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
            let (_sign, s, _exp) = f.to_sign_string_exp(10, None);
            //eprintln!("for d={} s='{}' (width={})", d, s, s.len());
            if s.len() <= max_cycle {
                //eprintln!("  ...shorter than max_cycle={}", max_cycle);
                continue;
            }
            let cycle_s = Self::recurring_cycle(&s);
            if cycle_s.len() <= max_cycle {
                //eprintln!("  ...cycle_s='{}' shorter than max_cycle={}", cycle_s, max_cycle);
                continue;
            }
            //eprintln!("  ...cycle_s='{}' longer than previous max_cycle={}", cycle_s, max_cycle);
            max_cycle = cycle_s.len();
            max_d = d;
        }
        max_d
    }

    fn recurring_cycle(s: &str) -> String {
        // the last N digits can be incorrect due to precision
        const FUDGE: usize = 3;
        for i in 0..s.len() {
            let ich = s.chars().nth(i).unwrap();
            for j in i+1..s.len() {
                if s.chars().nth(j).unwrap() == ich {
                    let mut width = j - i;
                    if j + width > s.len() {
                        //eprintln!("  ...OVERFLOW i={} ich='{}' vs j={} jstr='{}' width={}", i, ich, j, &s[j..], width);
                        break;
                    }
                    let left = &s[i..j];
                    let right = &s[j..j+width];
                    if left == right {
                        //eprintln!("  ...MATCH i={} ich='{}' vs j={} jstr='{}' width={} left='{}' right='{}'", i, ich, j, &s[j..], width, left, right);
                        let mut k = j + width;
                        while k + width < s.len() - FUDGE {
                            let rpt = &s[k..k+width];
                            if rpt != left {
                                //eprintln!("    ...but MISMATCH i={} ich='{}' left='{}' vs k={} kstr='{}' rpt='{}'", i, ich, left, k, &s[k..], rpt);
                                width = 0;
                                break;
                            }
                            k += width;
                        }
                        if width == 0 {
                            continue;  // from MISMATCH
                        }
                        //eprintln!("    ...and it repeats to end");
                        return String::from(left);
                    }
                }
            }
        }
        String::from("")
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
