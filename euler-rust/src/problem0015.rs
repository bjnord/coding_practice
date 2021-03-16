/// Problem 15: [Lattice paths](https://projecteuler.net/problem=15)

pub struct Problem0015 { }

impl Problem0015 {
    /// How many unique down/right paths can be taken through an `n`x`n`
    /// grid?
    //
    // We need to make 2*n moves of two types (n down and n right) in any
    // order. This is a permutation/combination problem; the formula for a
    // combination without replacement is: `c! / ((c - m)! * m!)`
    // where `c` is the possible choices, and `m` is how many we choose
    //
    // for n=2 (the given example), c=4 and m=2, so we get:
    // `4! / (2! * 2!)  =  4*3*2*1 / (2*1 * 2*1)  =  4*3 / 2*1`
    // and this is 6, the example answer
    //
    // for n=4, c=8 and m=4, so we get:
    // `8! / (4! * 4!)  =  8*7*6*5*4*3*2*1 / (4*3*2*1 * 4*3*2*1)  =  8*7*6*5 / 4*3*2*1`
    // the first factorial in the denominator will always cancel the lower
    // half of the factorial in the numerator
    //
    // so the generalization should be:
    // `(n*2) * (n*2-1) * ... * (n+1) / n * (n-1) * ... * 1`
    //
    // interestingly, the even terms in the numerator divide evenly into the
    // first half of the terms in the denominator, leaving an extra 2 on top
    // for each; we take advantage of this to make the calculation fit
    // within a `usize`
    #[must_use]
    pub fn solve(n: usize) -> usize {
        if n & 0x1 == 0x1 {
            panic!("only even grid sizes supported");
        }
        let num: usize = ((n+1)..=(n*2)).filter(|i| i & 0x1 == 0x1).product();
        let denom: usize = (1..=(n/2)).product();
        let twos: usize = 2_usize.pow((n as u32) / 2);
        num * twos / denom
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 15 answer is {}", Self::solve(20))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0015::solve(2);
        assert_eq!(6, answer);
    }

    #[test]
    fn test_solve_example_4() {
        let answer = Problem0015::solve(4);
        assert_eq!(70, answer);
    }

    #[test]
    fn test_solve_example_6() {
        let answer = Problem0015::solve(6);
        assert_eq!(924, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0015::solve(20);
        assert_eq!(137846528820, answer);
    }
}
