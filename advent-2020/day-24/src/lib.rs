use custom_error::custom_error;
use std::collections::HashSet;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub FlipListError
    InvalidChar{ch: char} = "invalid tile character '{ch}'",
    Empty = "tile is empty",
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Tile {
    dirs: Vec<String>,
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        writeln!(f, "{:?}", self)
    }
}

impl FromStr for Tile {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let mut dirs: Vec<String> = vec![];
        let mut ns: Option<char> = None;
        for ch in input.trim().chars() {
            match ch {
                'n' | 's' => ns = Some(ch),
                'e' | 'w' => {
                    if let Some(ch0) = ns {
                        dirs.push(format!("{}{}", ch0, ch));
                        ns = None;
                    } else {
                        dirs.push(format!("{}", ch));
                    }
                },
                _ => return Err(FlipListError::InvalidChar { ch }.into()),
            }
        }
        if dirs.is_empty() {
            return Err(FlipListError::Empty.into());
        }
        Ok(Self { dirs })
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct FlipList {
    tiles: Vec<Tile>,
}

impl fmt::Display for FlipList {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for tile in &self.tiles {
            s += &format!("{}\n", tile);
        }
        write!(f, "{}", s)
    }
}

impl FlipList {
    /// Construct by reading tiles from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<FlipList> {
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
    fn test_parse_tile() {
        let tile: Tile = "esenee".parse().unwrap();
        assert_eq!(vec!["e", "se", "ne", "e"], tile.dirs);
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
        let flip_list = FlipList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(20, flip_list.tiles.len());
        assert_eq!(vec!["se", "se", "nw", "ne", "ne", "ne", "w", "se", "e", "sw"], &flip_list.tiles[0].dirs[0..10]);
    }
}
