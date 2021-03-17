/// Problem 18: [Maximum path sum I](https://projecteuler.net/problem=18)

use crate::euler::NumberTriangle;

pub struct Problem0018 {
    tri: Vec<Vec<u32>>,
}

impl Problem0018 {
    /// Construct the problem triangle.
    pub fn new() -> Self {
        let tri: Vec<Vec<u32>> = vec![
            vec![75],
            vec![95, 64],
            vec![17, 47, 82],
            vec![18, 35, 87, 10],
            vec![20,  4, 82, 47, 65],
            vec![19,  1, 23, 75,  3, 34],
            vec![88,  2, 77, 73,  7, 63, 67],
            vec![99, 65,  4, 28,  6, 16, 70, 92],
            vec![41, 41, 26, 56, 83, 40, 80, 70, 33],
            vec![41, 48, 72, 33, 47, 32, 37, 16, 94, 29],
            vec![53, 71, 44, 65, 25, 43, 91, 52, 97, 51, 14],
            vec![70, 11, 33, 28, 77, 73, 17, 78, 39, 68, 17, 57],
            vec![91, 71, 52, 38, 17, 14, 91, 43, 58, 50, 27, 29, 48],
            vec![63, 66,  4, 68, 89, 53, 67, 30, 73, 16, 69, 87, 40, 31],
            vec![ 4, 62, 98, 27, 23,  9, 70, 98, 73, 93, 38, 53, 60,  4, 23],
        ];
        Self { tri }
    }

    /// Find the maximum-sum path through the given number triangle.
    #[must_use]
    pub fn solve(&self) -> u32 {
        NumberTriangle::max_sum(&self.tri).unwrap()
    }

    #[must_use]
    pub fn output() -> String {
        let problem = Problem0018::new();
        format!("Problem 18 answer is {}", problem.solve())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // the example is in euler::NumberTriangle

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let problem = Problem0018::new();
        assert_eq!(1074, problem.solve());
    }
}
