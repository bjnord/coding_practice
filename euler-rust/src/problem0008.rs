/// Problem 8: [Largest product in a series](https://projecteuler.net/problem=8)

pub struct Problem0008 { }

const BIG_NUMBER: &str = "73167176531330624919225119674426574742355349194934\
    96983520312774506326239578318016984801869478851843\
    85861560789112949495459501737958331952853208805511\
    12540698747158523863050715693290963295227443043557\
    66896648950445244523161731856403098711121722383113\
    62229893423380308135336276614282806444486645238749\
    30358907296290491560440772390713810515859307960866\
    70172427121883998797908792274921901699720888093776\
    65727333001053367881220235421809751254540594752243\
    52584907711670556013604839586446706324415722155397\
    53697817977846174064955149290862569321978468622482\
    83972241375657056057490261407972968652414535100474\
    82166370484403199890008895243450658541227588666881\
    16427171479924442928230863465674813919123162824586\
    17866458359124566529476545682848912883142607690042\
    24219022671055626321111109370544217506941658960408\
    07198403850962455444362981230987879927244284909188\
    84580156166097919133875499200524063689912560717606\
    05886116467109405077541002256983155200055935729725\
    71636269561882670428252483600823257530420752963450";

impl Problem0008 {
    /// Find the sequence of `n` digits in the big string with the greatest
    /// product.
    #[must_use]
    pub fn solve(n: usize) -> u64 {
        // insight: any sequence with a 0 digit results in product=0
        // so just look at sequences between 0 digit "separators"
        BIG_NUMBER.split('0')
            .map(|seq| Self::max_product(seq, n))
            .max()
            .unwrap()
    }

    // Find the sub-sequence of `n` digits in the given `seq` with the
    // greatest product.
    fn max_product(seq: &str, n: usize) -> u64 {
        if seq.len() < n {
            return 0;
        }
        // find greatest product of all n-length sub-sequences
        (0..=(seq.len()-n))
            .map(|i| Self::digit_product(&seq[i..(i+n)]))
            .max()
            .unwrap()
    }

    fn digit_product(seq: &str) -> u64 {
        seq.chars().map(|c| c.to_digit(10).unwrap() as u64).product()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 8 answer is {}", Self::solve(13))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0008::solve(4);
        assert_eq!(5832, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0008::solve(13);
        assert_eq!(23514624000, answer);
    }
}
