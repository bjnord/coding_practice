/// Problem 28: [Number spiral diagonals](https://projecteuler.net/problem=28)

use std::convert::TryFrom;

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
enum Dir {
    Out,
    Down,
    Left,
    Up,
    Right,
}

impl Dir {
    fn next(dir: Dir) -> Dir {
        match dir {
            Dir::Out => Dir::Down,
            Dir::Down => Dir::Left,
            Dir::Left => Dir::Up,
            Dir::Up => Dir::Right,
            Dir::Right => Dir::Out,
        }
    }
}

pub struct NumberSpiral {
    cells: Vec<usize>,
    edge: usize,
}

impl NumberSpiral {
    /// Construct an `n`x`n` number spiral, starting with the number 1
    /// and moving to the right in a clockwise direction.
    ///
    /// For example, a 5x5 number spiral looks like:
    ///
    /// `21 22 23 24 25`
    ///
    /// `20  7  8  9 10`
    ///
    /// `19  6  1  2 11`
    ///
    /// `18  5  4  3 12`
    ///
    /// `17 16 15 14 13`
    ///
    pub fn new(n: usize) -> Self {
        if (n & 0x1 == 0x0) || n < 3 {
            panic!("only odd-numbered grids 3x3 or larger are supported");
        }
        let n_cells = n * n;
        let mut cells: Vec<usize> = vec![0; n_cells];
        // start by putting the 1 in the center (ring 0)
        let mut y = 0_i32;
        let mut x = 0_i32;
        let mut ring = 0_usize;
        cells[Self::index(y, x, n)] = 1;
        // do the spiral
        let mut dir: Dir = Dir::Out;
        let mut count = 0_usize;
        for i in 2..=n_cells {
            match dir {
                Dir::Out => {
                    x += 1;
                    dir = Dir::next(dir);
                    // NB Down goes one less than the other directions
                    //    but the increment below consumes 1
                    count = 0;
                    ring += 1;
                },
                Dir::Down => y += 1,
                Dir::Left => x -= 1,
                Dir::Up => y -= 1,
                Dir::Right => x += 1,
            }
            count += 1;
            if count >= ring*2 {
                dir = Dir::next(dir);
                count = 0;
            }
            cells[Self::index(y, x, n)] = i;
        }
        Self { cells, edge: n }
    }

    // Compute `cells[]` vector index from a (y,x) position.
    fn index(y: i32, x: i32, n: usize) -> usize {
        let half: i32 = i32::try_from(n / 2).unwrap();
        if y < -half || y > half {
            panic!("y={} out of range for n={}", y, n);
        }
        if x < -half || x > half {
            panic!("x={} out of range for n={}", x, n);
        }
        let n_i: i32 = i32::try_from(n).unwrap();
        usize::try_from((y + half) * n_i + x + half).unwrap()
    }

    /// Compute the sum of both diagonals.
    ///
    /// # Examples
    ///
    /// ```
    /// # use euler_rust::problem0028::NumberSpiral;
    /// let spiral = NumberSpiral::new(5);
    /// assert_eq!(101, spiral.diagonal_sum());
    /// ```
    pub fn diagonal_sum(&self) -> usize {
        let edge_i = i32::try_from(self.edge).unwrap();
        let half = edge_i / 2;
        let mut ul_sum = 0_usize;
        let mut ur_sum = 0_usize;
        for y in -half..=half {
            ul_sum += self.cells[Self::index(y, y, self.edge)];
            ur_sum += self.cells[Self::index(y, -y, self.edge)];
        }
        ul_sum + ur_sum - 1  // subtract center-cell duplicate
    }
}

pub struct Problem0028 {
}

impl Problem0028 {
    /// Find the sum of the numbers on the diagonals in an `n`x`n` number
    /// spiral.
    #[must_use]
    pub fn solve(n: usize) -> usize {
        let spiral = NumberSpiral::new(n);
        spiral.diagonal_sum()
    }

    #[must_use]
    pub fn output() -> String {
        format!("Problem 28 answer is {}", Self::solve(1_001))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_solve_example() {
        let answer = Problem0028::solve(5);
        assert_eq!(101, answer);
    }

    #[test]
    #[ignore]
    fn test_solve_problem() {
        let answer = Problem0028::solve(1_001);
        assert_eq!(669171001, answer);
    }

    #[test]
    fn test_index() {
        assert_eq!(0, NumberSpiral::index(-1, -1, 3));
        assert_eq!(1, NumberSpiral::index(-1, 0, 3));
        assert_eq!(3, NumberSpiral::index(0, -1, 3));
        assert_eq!(4, NumberSpiral::index(0, 0, 3));
        assert_eq!(5, NumberSpiral::index(0, 1, 3));
        assert_eq!(7, NumberSpiral::index(1, 0, 3));
        assert_eq!(8, NumberSpiral::index(1, 1, 3));
    }

    #[test]
    #[should_panic]
    fn test_low_y_index() {
        NumberSpiral::index(-2, -1, 3);
    }

    #[test]
    #[should_panic]
    fn test_low_x_index() {
        NumberSpiral::index(-1, -2, 3);
    }

    #[test]
    #[should_panic]
    fn test_high_y_index() {
        NumberSpiral::index(2, 1, 3);
    }

    #[test]
    #[should_panic]
    fn test_high_x_index() {
        NumberSpiral::index(1, 2, 3);
    }

    #[test]
    fn test_construct() {
        let spiral = NumberSpiral::new(5);
        let exp = vec![
            21, 22, 23, 24, 25,
            20,  7,  8,  9, 10,
            19,  6,  1,  2, 11,
            18,  5,  4,  3, 12,
            17, 16, 15, 14, 13,
        ];
        assert_eq!(exp, spiral.cells);
    }
}
