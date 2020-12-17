use std::fmt;
use std::fs;
use std::result;

type Result<T> = result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, PartialEq)]
pub struct Position {
    coords: Vec<i32>,
}

impl Position {
    #[allow(clippy::cast_sign_loss)]
    fn index(edge: i32, z: i32, y: i32, x: i32) -> usize {
        ((z * edge + y) * edge + x) as usize
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
    edge: i32,
}

impl fmt::Display for InfiniteGrid {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for z in 0..self.edge {
            let label = format!("z={}\n", z);
            s += &label;
            for y in 0..self.edge {
                for x in 0..self.edge {
                    s += match self.cube_at(z, y, x) {
                        ConwayCube::Void => "_",
                        ConwayCube::Inactive => ".",
                        ConwayCube::Active => "#",
                    };
                }
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
        if self.layout == prev_layout { None } else { Some(self.layout.clone()) }
    }
}

impl InfiniteGrid {
    /// Construct by reading grid from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened.
    pub fn read_from_file(path: &str, margin: i32) -> Result<InfiniteGrid> {
        let s: String = fs::read_to_string(path)?;
        InfiniteGrid::from_input(&s, margin)
    }

    /// Construct by reading grid from `input` string.
    pub fn from_input(input: &str, margin: i32) -> Result<InfiniteGrid> {
        let line_len = input.lines().next().unwrap().len() as i32;
        let edge = line_len + margin * 2;
        let cubes_2d: Vec<ConwayCube> = input
            .lines()
            .flat_map(|line| line.trim().chars().map(ConwayCube::from_char))
            .collect();
        let mut cubes: Vec<ConwayCube> = vec![ConwayCube::Void; (edge * edge * edge) as usize];
        let z = line_len / 2;
        for y in 0..line_len {
            for x in 0..line_len {
                let from_i = (y * line_len + x) as usize;
                let to_z = z + margin;
                let to_y = y + margin;
                let to_x = x + margin;
                let to_i = ((to_z * edge + to_y) * edge + to_x) as usize;
                cubes[to_i] = cubes_2d[from_i];
            }
        }
        Ok(Self { cubes, edge })
    }

    #[must_use]
    pub fn iter(&self) -> InfiniteGridIter {
        InfiniteGridIter {
            layout: self.clone(),
        }
    }

    /// Return `ConwayCube` at (z, y, x).
    #[must_use]
    pub fn cube_at(&self, z: i32, y: i32, x: i32) -> ConwayCube {
        match (z, y, x) {
            (z, _, _) if z < 0 || z >= self.edge => ConwayCube::Void,
            (_, y, _) if y < 0 || y >= self.edge => ConwayCube::Void,
            (_, _, x) if x < 0 || x >= self.edge => ConwayCube::Void,
            _ => {
                self.cubes[Position::index(self.edge, z, y, x)]
            },
        }
    }

    /// Return count of active cubes.
    #[must_use]
    pub fn active_cubes(&self) -> usize {
        self.cubes.iter().filter(|&c| *c == ConwayCube::Active).count()
    }

    /// Return count of active neighbor cubes of `(y, x)`.
    #[must_use]
    pub fn active_neighbors_at(&self, z: i32, y: i32, x: i32) -> usize {
        let mut n_active: usize = 0;
        for dz in -1..=1 {
            for dy in -1..=1 {
                for dx in -1..=1 {
                    if dz == 0 && dy == 0 && dx == 0 {
                        continue;
                    }
                    if self.cube_at(z + dz, y + dy, x + dx) == ConwayCube::Active {
                        n_active += 1;
                    }
                }
            }
        }
        n_active
    }

    /// Do one round of cube life.
    #[must_use]
    pub fn cube_round(&self) -> InfiniteGrid {
        let mut cubes = Vec::<ConwayCube>::new();
        for z in 0..self.edge {
            for y in 0..self.edge {
                for x in 0..self.edge {
                    cubes.push(self.new_cube_at(z, y, x));
                }
            }
        }
        InfiniteGrid { cubes, edge: self.edge }
    }

    fn new_cube_at(&self, z: i32, y: i32, x: i32) -> ConwayCube {
        match self.cube_at(z, y, x) {
            ConwayCube::Active => {
                let n = self.active_neighbors_at(z, y, x);
                if n == 2 || n == 3 {
                    ConwayCube::Active
                } else {
                    ConwayCube::Inactive
                }
            },
            _ => {
                if self.active_neighbors_at(z, y, x) == 3 {
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
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 1).unwrap();
        assert_eq!(5, grid.edge);
        assert_eq!(5, grid.active_cubes());
    }

    #[test]
    fn test_grid_indexing() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 1).unwrap();
        assert_eq!(ConwayCube::Active, grid.cube_at(2, 1, 2));
        assert_eq!(ConwayCube::Inactive, grid.cube_at(2, 2, 1));
    }

    #[test]
    fn test_grid_indexing_void_z() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 1).unwrap();
        assert_eq!(ConwayCube::Void, grid.cube_at(-1, 1, 2));
        assert_eq!(ConwayCube::Void, grid.cube_at(1, 2, 1));
    }

    #[test]
    fn test_grid_indexing_void_y() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 1).unwrap();
        assert_eq!(ConwayCube::Void, grid.cube_at(2, -1, 2));
        assert_eq!(ConwayCube::Void, grid.cube_at(2, 0, 1));
    }

    #[test]
    fn test_grid_indexing_void_x() {
        let grid = InfiniteGrid::from_input(TINY_LAYOUT, 1).unwrap();
        assert_eq!(ConwayCube::Void, grid.cube_at(2, 1, -1));
        assert_eq!(ConwayCube::Void, grid.cube_at(2, 2, 0));
    }
}
