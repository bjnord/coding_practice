use itertools::Itertools;
use std::fmt;
use std::fs;

pub const N_ROUNDS: usize = 6;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, PartialEq)]
pub struct Position {
    coords: Vec<i32>,
}

impl Position {
    /// Return linear index of position, given `edge` length of grid.
    #[allow(clippy::cast_sign_loss)]
    #[must_use]
    pub fn index_for(&self, edge: i32) -> usize {
        let mut i = 0_i32;
        for c in &self.coords {
            i = i * edge + c;
        }
        i as usize
    }

    #[must_use]
    /// Construct from n-dimensional coordinates.
    pub fn from(coords: &[i32]) -> Self {
        Self { coords: coords.iter().copied().collect() }
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum ConwayCube {
    Void,
    Inactive,
    Active,
}

impl ConwayCube {
    /// Construct cube from input character.
    #[must_use]
    pub fn from_char(cube: char) -> ConwayCube {
        match cube {
            '.' => ConwayCube::Inactive,
            '#' => ConwayCube::Active,
            _ => {
                let e = format!("invalid cube character {}", cube);
                panic!(e);
            }
        }
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct InfiniteGrid {
    cubes: Vec<ConwayCube>,
    dim: usize,
    edge: i32,
}

impl fmt::Display for InfiniteGrid {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let half_edge = self.edge / 2;
        let mut s = String::new();
        for coords in (0..self.dim).map(|_i| 0..self.edge).multi_cartesian_product() {
            if coords[self.dim - 2] == 0 && coords[self.dim - 1] == 0 {
                let axes = vec!['z', 'w', 'v', 'u'];
                for d in 2..self.dim {
                    if d > 2 {
                        s += ", ";
                    }
                    let label = format!("{}={}", axes[d - 2], coords[self.dim - d - 1] - half_edge);
                    s += &label;
                }
                s += "\n";
            }
            let pos = Position::from(&coords);
            s += match self.cube_at(&pos) {
                ConwayCube::Void => "_",
                ConwayCube::Inactive => ".",
                ConwayCube::Active => "#",
            };
            if coords[self.dim - 1] >= self.edge - 1 {
                s += "\n";
            }
        }
        write!(f, "{}", s)
    }
}

pub struct InfiniteGridIter {
    layout: InfiniteGrid,
}

impl Iterator for InfiniteGridIter {
    type Item = InfiniteGrid;

    fn next(&mut self) -> Option<Self::Item> {
        let prev_layout = self.layout.clone();
        self.layout = prev_layout.cube_round();
        Some(self.layout.clone())
    }
}

impl InfiniteGrid {
    /// Return edge length.
    #[must_use]
    pub fn edge(&self) -> i32 {
        self.edge
    }

    /// Construct `InfiniteGrid` of dimension `dim`  by reading initial grid
    /// plane from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened.
    pub fn read_from_file(path: &str, dim: usize) -> Result<InfiniteGrid> {
        let s: String = fs::read_to_string(path)?;
        InfiniteGrid::from_input(&s, dim)
    }

    /// Construct `InfiniteGrid` of dimension `dim`  by reading initial grid
    /// plane from `input` string.
    pub fn from_input(input: &str, dim: usize) -> Result<InfiniteGrid> {
        let edge = input.lines().next().unwrap().len() as i32;
        let half_edge = edge / 2;
        // parse and store initial 2D grid plane:
        let cubes_2d: Vec<ConwayCube> = input
            .lines()
            .flat_map(|line| line.trim().chars().map(ConwayCube::from_char))
            .collect();
        // create empty nD grid, and copy initial 2D grid plane to it
        // (in the middle of each dimension beyond the first two):
        let max_i = InfiniteGrid::index_size(edge, dim);
        let mut cubes: Vec<ConwayCube> = vec![ConwayCube::Void; max_i];
        for y in 0..edge {
            for x in 0..edge {
                let from_i = (y * edge + x) as usize;
                let mut dims = vec![half_edge; dim];
                dims[dim-1] = x;
                dims[dim-2] = y;
                let to_i = Position::from(&dims).index_for(edge);
                cubes[to_i] = cubes_2d[from_i];
            }
        }
        Ok(Self { cubes, dim, edge })
    }

    #[must_use]
    fn index_size(edge: i32, dim: usize) -> usize {
        let mut s = 1_i32;
        for _i in 0..dim {
            s *= edge;
        }
        s as usize
    }

    #[must_use]
    pub fn iter(&self) -> InfiniteGridIter {
        InfiniteGridIter {
            layout: self.clone(),
        }
    }

    /// Return `ConwayCube` at the given position.
    #[must_use]
    pub fn cube_at(&self, pos: &Position) -> ConwayCube {
        for c in &pos.coords {
            if *c < 0 || *c >= self.edge {
                return ConwayCube::Void;
            }
        }
        self.cubes[pos.index_for(self.edge)]
    }

    /// Return count of active cubes.
    #[must_use]
    pub fn active_cubes(&self) -> usize {
        self.cubes.iter().filter(|&c| *c == ConwayCube::Active).count()
    }

    /// Return count of active neighbor cubes of the cube at the given
    /// position.
    #[must_use]
    pub fn active_neighbors_at(&self, pos: &Position) -> usize {
        let mut n_active: usize = 0;
        for deltas in (0..self.dim).map(|_i| -1..=1).multi_cartesian_product() {
            if deltas.iter().all(|dc| *dc == 0) {
                continue;
            }
            let d_coords: Vec<i32> = pos.coords
                .iter()
                .enumerate()
                .map(|(i, dc)| *dc + deltas[i])
                .collect();
            let d_pos = Position::from(&d_coords);
            if self.cube_at(&d_pos) == ConwayCube::Active {
                n_active += 1;
            }
        }
        n_active
    }

    /// Do one round of cube life. Returns a new grid which is one unit
    /// bigger in all directions (its edge increases by 2 in all
    /// dimensions).
    #[must_use]
    pub fn cube_round(&self) -> InfiniteGrid {
        let edge = self.edge + 2;
        let max_i = InfiniteGrid::index_size(edge, self.dim);
        let mut cubes: Vec<ConwayCube> = vec![ConwayCube::Void; max_i];
        for coords in (0..self.dim).map(|_i| 0..edge).multi_cartesian_product() {
            let from_coords: Vec<i32> = coords.iter().map(|c| c - 1).collect();
            let from_pos = Position::from(&from_coords);
            let pos = Position::from(&coords);
            cubes[pos.index_for(edge)] = self.new_cube_at(&from_pos);
        }
        InfiniteGrid { cubes, dim: self.dim, edge }
    }

    fn new_cube_at(&self, pos: &Position) -> ConwayCube {
        match self.cube_at(&pos) {
            ConwayCube::Active => {
                let n = self.active_neighbors_at(&pos);
                if n == 2 || n == 3 {
                    ConwayCube::Active
                } else {
                    ConwayCube::Inactive
                }
            },
            _ => {
                if self.active_neighbors_at(&pos) == 3 {
                    ConwayCube::Active
                } else {
                    ConwayCube::Inactive
                }
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const TINY_LAYOUT: &'static str = ".#.\n..#\n###\n";

    #[test]
    fn test_from_input() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 3).unwrap();
        assert_eq!(3, grid.edge);
        assert_eq!(5, grid.active_cubes());
    }

    #[test]
    fn test_grid_indexing() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 3).unwrap();
        let pos = Position::from(&[1, 0, 1]);
        assert_eq!(ConwayCube::Active, grid.cube_at(&pos));
        let pos = Position::from(&[1, 1, 0]);
        assert_eq!(ConwayCube::Inactive, grid.cube_at(&pos));
        let pos = Position::from(&[0, 1, 0]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
    }

    #[test]
    fn test_grid_indexing_void_z() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 3).unwrap();
        let pos = Position::from(&[-1, 0, 1]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
        let pos = Position::from(&[3, 1, 0]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
    }

    #[test]
    fn test_grid_indexing_void_y() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 3).unwrap();
        let pos = Position::from(&[1, -1, 1]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
        let pos = Position::from(&[1, 3, 0]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
    }

    #[test]
    fn test_grid_indexing_void_x() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 3).unwrap();
        let pos = Position::from(&[1, 0, -1]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
        let pos = Position::from(&[1, 1, 3]);
        assert_eq!(ConwayCube::Void, grid.cube_at(&pos));
    }

    #[test]
    fn test_6_rounds() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 3).unwrap();
        let mut n_active: usize = 0;
        for (i, g) in grid.iter().enumerate() {
            if i >= N_ROUNDS - 1 {
                n_active = g.active_cubes();
                break;
            }
        }
        assert_eq!(112, n_active);
    }

    #[test]
    fn test_6_rounds_4d() {
        // the full N_ROUNDS takes a while so:
        let n_rounds = 1;  // = N_ROUNDS;
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 4).unwrap();
        let mut n_active: usize = 0;
        for (i, g) in grid.iter().enumerate() {
            if i >= n_rounds - 1 {
                n_active = g.active_cubes();
                break;
            }
        }
        let expect = if n_rounds == 1 { 3*4 + 5 + 3*4 } else { 848 };
        assert_eq!(expect, n_active);
    }
}
