/// Problem 22: [Names scores](https://projecteuler.net/problem=22)

use std::fs;

pub struct Problem0022 { }

impl Problem0022 {
    /// Find the total of all name scores in the input file.
    #[must_use]
    pub fn solve() -> u32 {
        let mut names: Vec<String> = Self::read_names("input/p022_names.txt");
        names.sort();
        names.iter().enumerate()
            .map(|(i, name)| (i as u32 + 1) * Self::alpha_score(name))
            .sum()
    }

    fn read_names(filename: &str) -> Vec<String> {
        fs::read_to_string(filename).unwrap()
            .trim()
            .split(',')
            .map(|s| s.replace("\"", ""))
            .collect()
    }

    fn alpha_score(name: &str) -> u32 {
        name.chars().map(|c| (c as u32) - 64).sum()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 22 answer is {}", Self::solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0022::solve();
        assert_eq!(871198282, answer);
    }

    #[test]
    fn test_alpha_score() {
        let answer = Problem0022::alpha_score("COLIN");
        assert_eq!(53, answer);
    }
}
