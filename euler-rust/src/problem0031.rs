/// Problem 31: [Coin sums](https://projecteuler.net/problem=31)

pub struct Problem0031 { }

impl Problem0031 {
    /// Find the number of ways to express `amount` using `coins` of the
    /// given denomination.
    #[must_use]
    pub fn solve(amount: u32, coins: &[u32]) -> u32 {
        // bottom of recursive chain: only one way to express the amount,
        // namely amount * 1p
        if coins.len() == 1 {
            if coins[0] != 1 {
                panic!("unsupported: lowest coin must be 1");
            }
            return 1;
        }
        if coins[0] <= coins[1] {
            panic!("unsupported: coins must be in descending order");
        }
        let mut combos = 0_u32;
        for i in 0..=amount {
            // if my denomination divides evenly, that's another way to
            // express the amount
            if i * coins[0] == amount {
                combos += 1;
            }
            // once we meet or exceed the amount, we're done
            if i * coins[0] >= amount {
                break;
            }
            // otherwise, call recursively to find number of ways to
            // express the remaining amount
            combos += Self::solve(amount - i * coins[0], &coins[1..]);
        }
        combos
    }

    #[must_use]
    pub fn output() -> String {
        let coins = vec![200_u32, 100_u32, 50_u32, 20_u32, 10_u32, 5_u32, 2_u32, 1_u32];
        format!("Problem 31 answer is {}", Self::solve(200, &coins))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        // 10p
        // 5p/5p
        // 5p + 2p/2p + 1p
        // 5p + 2p + 1p/1p/1p
        // 5p + 1p/1p/1p/1p/1p
        // 2p/2p/2p/2p/2p
        // 2p/2p/2p/2p + 1p/1p
        // 2p/2p/2p + 1p/1p/1p/1p
        // 2p/2p + 1p/1p/1p/1p/1p/1p
        // 2p + 1p/1p/1p/1p/1p/1p/1p/1p
        // 1p/1p/1p/1p/1p/1p/1p/1p/1p/1p
        let coins = vec![10_u32, 5_u32, 2_u32, 1_u32];
        let answer = Problem0031::solve(10, &coins);
        assert_eq!(11, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let coins = vec![200_u32, 100_u32, 50_u32, 20_u32, 10_u32, 5_u32, 2_u32, 1_u32];
        let answer = Problem0031::solve(200, &coins);
        assert_eq!(73682, answer);
    }
}
