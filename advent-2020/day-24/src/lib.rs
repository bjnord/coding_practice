use custom_error::custom_error;
use std::collections::HashSet;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub FloorError
    InvalidChar{ch: char} = "invalid tile character '{ch}'",
    InvalidDir{dir: String} = "invalid tile direction '{dir}'",
    Empty = "tile is empty",
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
// this uses "axial" a.k.a. "trapezoidal" coordinates
// the flat side of the puzzle hexes is on the left/right
// x = horizontal axis, y = tilted vertical axis
// <https://math.stackexchange.com/questions/2254655/hexagon-grid-coordinate-system>
pub struct Pos {
    y: i32,
    x: i32,
}

impl FromStr for Pos {
    type Err = Box<dyn std::error::Error>;

    fn from_str(dir: &str) -> Result<Self> {
        match dir {
            "e" => Ok(Self::E),
            "w" => Ok(Self::W),
            "se" => Ok(Self::SE),
            "nw" => Ok(Self::NW),
            "sw" => Ok(Self::SW),
            "ne" => Ok(Self::NE),
            _ => return Err(FloorError::InvalidDir { dir: dir.to_string() }.into()),
        }
    }
}

impl Pos {
    const E: Self = Self { x: 1, y: 0 };
    const W: Self = Self { x: -1, y: 0 };
    const SE: Self = Self { x: 0, y: 1 };
    const NW: Self = Self { x: 0, y: -1 };
    const SW: Self = Self { x: -1, y: 1 };
    const NE: Self = Self { x: 1, y: -1 };

    #[must_use]
    pub fn sum(poses: &Vec<Self>) -> Self {
        poses.iter().fold(Self { y: 0, x: 0 }, |acc, pos| {
            Self { y: acc.y + pos.y, x: acc.x + pos.x }
        })
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Tile {
    dirs: Vec<Pos>,
    pos: Pos,
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        writeln!(f, "{:?}", self)
    }
}

impl FromStr for Tile {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let mut dirs: Vec<Pos> = vec![];
        let mut ns: Option<char> = None;
        for ch in input.trim().chars() {
            match ch {
                'n' | 's' => {
                    if let Some(ch0) = ns {
                        let dir = format!("{}{}", ch0, ch);
                        return Err(FloorError::InvalidDir { dir }.into());
                    } else {
                        ns = Some(ch);
                    }
                }
                'e' | 'w' => {
                    let dir = if let Some(ch0) = ns {
                        ns = None;
                        format!("{}{}", ch0, ch)
                    } else {
                        format!("{}", ch)
                    };
                    let dir: Pos = dir.parse()?;
                    dirs.push(dir);
                },
                _ => return Err(FloorError::InvalidChar { ch }.into()),
            }
        }
        if dirs.is_empty() {
            return Err(FloorError::Empty.into());
        }
        let pos = Pos::sum(&dirs);
        Ok(Self { dirs, pos })
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Floor {
    tiles: Vec<Tile>,
}

impl fmt::Display for Floor {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for tile in &self.tiles {
            s += &format!("{}\n", tile);
        }
        write!(f, "{}", s)
    }
}

impl Floor {
    /// Construct by reading tiles from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<Floor> {
        let s: String = fs::read_to_string(path)?;
        let tiles: Vec<Tile> = s
            .trim()
            .split("\n")
            .map(str::parse)
            .collect::<Result<Vec<Tile>>>()?;
        Ok(Self { tiles })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // esenee identifies the tile you land on if you start at the reference tile and then move one
    // tile east, one tile southeast, one tile northeast, and one tile east

    #[test]
    fn test_parse_dir() {
        let dir: Pos = "sw".parse().unwrap();
        assert_eq!(Pos { y: 1, x: -1 }, dir);
    }

    #[test]
    fn test_parse_dir_invalid_char() {
        match "nne".parse::<Tile>() {
            Err(e) => assert_eq!("invalid tile direction 'nn'", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_parse_tile() {
        let tile: Tile = "esenee".parse().unwrap();
        assert_eq!(vec![Pos::E, Pos::SE, Pos::NE, Pos::E], tile.dirs);
        assert_eq!(Pos { y: 0, x: 3 }, Pos::sum(&tile.dirs));
    }

    #[test]
    fn test_parse_tile_2() {
        let tile: Tile = "esew".parse().unwrap();
        assert_eq!(vec![Pos::E, Pos::SE, Pos::W], tile.dirs);
        assert_eq!(Pos { y: 1, x: 0 }, Pos::sum(&tile.dirs));
    }

    #[test]
    fn test_parse_tile_3() {
        let tile: Tile = "nwwswee".parse().unwrap();
        assert_eq!(vec![Pos::NW, Pos::W, Pos::SW, Pos::E, Pos::E], tile.dirs);
        assert_eq!(Pos { y: 0, x: 0 }, Pos::sum(&tile.dirs));
    }

    #[test]
    fn test_parse_tile_empty() {
        match "".parse::<Tile>() {
            Err(e) => assert_eq!("tile is empty", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_parse_tile_invalid_char() {
        match "esenbe".parse::<Tile>() {
            Err(e) => assert_eq!("invalid tile character 'b'", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file() {
        let floor = Floor::read_from_file("input/example1.txt").unwrap();
        assert_eq!(20, floor.tiles.len());
        assert_eq!(vec![
            Pos::SE, Pos::SE, Pos::NW, Pos::NE, Pos::NE,
            Pos::NE, Pos::W, Pos::SE, Pos::E, Pos::SW,
        ], &floor.tiles[0].dirs[0..10]);
    }
}
