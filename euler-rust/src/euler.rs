/// Misc. Euler Project functions

use custom_error::custom_error;
use std::cmp;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub EulerError
    InvalidFormat = "invalid format",
}

pub struct NumberTriangle { }

impl NumberTriangle {
    /// Find the maximum-sum path through the given number triangle.
    //
    // The trick is to start at the bottom; each cell is replaced by the sum
    // of its value and the maximum of its two children; when we reach the
    // top, we have the max-path value alone at the top.
    pub fn max_sum(tri: &Vec<Vec<u32>>) -> Result<u32> {
        let mut prev_row: Vec<u32> = vec![];
        for row in tri.iter().rev() {
            if prev_row.is_empty() {  // bottom row has no children
                prev_row = row.to_vec();
                continue;
            }
            let mut max_row: Vec<u32> = vec![];
            for (i, n) in row.iter().enumerate() {
                let max_child = cmp::max(prev_row[i], prev_row[i+1]);
                max_row.push(n + max_child);
            }
            prev_row = max_row.to_vec();
        }
        Ok(prev_row[0])
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_number_triangle_max_sum() {
        let tri: Vec<Vec<u32>> = vec![
            vec![3],
            vec![7, 4],
            vec![2, 4, 6],
            vec![8, 5, 9, 3],
        ];
        assert_eq!(23, NumberTriangle::max_sum(&tri).unwrap());
    }

    // TODO test invalid triangle
}
