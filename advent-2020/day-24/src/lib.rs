use custom_error::custom_error;
use std::cmp;
use std::collections::HashMap;
use std::convert::TryFrom;
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

    /// Construct from (y, x) coordinates.
    pub fn new(y: i32, x: i32) -> Self {
        Self { y, x }
    }

    #[must_use]
    fn key(&self) -> i64 {
        let factor: i32 = 32_768;  // 2^15
        let offset: i32 = 1_073_741_824;  // 2^30
        if self.y.abs() > factor || self.x.abs() > factor {
            panic!("y={} x={} too large", self.y, self.x);
        }
        i64::try_from(offset + self.y * factor).unwrap() *
            i64::try_from(offset + self.x).unwrap()
    }

    /// Should this position be clipped (given floor dimension `idim`)?
    //
    // A full set of `(-y..=y, -x..=x)` positions produces a parallelogram,
    // which is usually not what we want. By clipping off two corners we get
    // a hexagon.
    #[must_use]
    pub fn clip(&self, idim: i32) -> bool {
        if self.y < 0 && self.x < 0 && self.y + self.x < -idim {
            return true;
        }
        if self.y > 0 && self.x > 0 && self.y + self.x > idim {
            return true;
        }
        false
    }

    /// Return sum of a list of position deltas.
    #[must_use]
    pub fn sum(poses: &[Self]) -> Self {
        poses.iter().fold(Self { y: 0, x: 0 }, |acc, pos| {
            Self { y: acc.y + pos.y, x: acc.x + pos.x }
        })
    }

    /// Return maximum of a list of position deltas. (The two dimensions are
    /// compared independently.)
    #[must_use]
    pub fn max(poses: &[Self]) -> Self {
        poses.iter().fold(Self { y: 0, x: 0 }, |acc, pos| {
            Self { y: cmp::max(acc.y, pos.y), x: cmp::max(acc.x, pos.x) }
        })
    }

    // Row-first increment (used by iterators).
    fn increment(&mut self, idim: i32) {
        self.x += 1;
        if self.x > idim {
            self.x = -idim;
            self.y += 1;
        }
    }
}

struct PosIter {
    idim: i32,
    pos: Pos,
}

impl Iterator for PosIter {
    type Item = Pos;

    fn next(&mut self) -> Option<Self::Item> {
        // first skip past clipped tiles
        while self.pos.y <= self.idim && self.pos.clip(self.idim) {
            self.pos.increment(self.idim);
        }
        // then find next tile
        let ret_pos = if self.pos.y > self.idim { None } else { Some(self.pos) };
        self.pos.increment(self.idim);
        ret_pos
    }
}

struct NonClipPosIter {
    idim: i32,
    pos: Pos,
}

impl Iterator for NonClipPosIter {
    type Item = Pos;

    fn next(&mut self) -> Option<Self::Item> {
        let ret_pos = if self.pos.y > self.idim { None } else { Some(self.pos) };
        self.pos.increment(self.idim);
        ret_pos
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum TileColor {
    White,
    Black,
}

impl TileColor {
    /// Return the opposite tile color.
    pub fn opposite(color: Self) -> Self {
        match color { Self::White => Self::Black, Self::Black => Self::White }
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

impl Tile {
    // Returns the maximum absolute-value (y, x) tile coordinates seen when
    // following the initial tile directions. (The two dimensions are
    // compared independently.)
    #[must_use]
    fn max_yx(&self) -> (usize, usize) {
        let zero = Pos::new(0, 0);
        let min_max_pos: Vec<Pos> = self.dirs
            .iter()
            .fold(vec![zero, zero, zero], |acc, pos| {
                let pos = Pos::sum(&[acc[2], *pos]);
                let min = Pos::new(cmp::min(acc[0].y, pos.y), cmp::min(acc[0].x, pos.x));
                let max = Pos::new(cmp::max(acc[1].y, pos.y), cmp::max(acc[1].x, pos.x));
                vec![min, max, pos]
            });
        let y = cmp::max(min_max_pos[0].y.abs(), min_max_pos[1].y);
        let x = cmp::max(min_max_pos[0].x.abs(), min_max_pos[1].x);
        (usize::try_from(y).unwrap(), usize::try_from(x).unwrap())
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Floor {
    dim: usize,
    idim: i32,
    initial_tiles: Vec<Tile>,
    colors: HashMap<i64, TileColor>,
}

impl fmt::Display for Floor {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for pos in self.nonclip_iter(self.dim) {
            if pos.x == -self.idim {
                for _ in 0..pos.y.abs() {
                    s += "  ";
                }
            }
            if !pos.clip(self.idim) {
                let color_s = match self.color_at(pos) {
                    Some(TileColor::Black) => " ## ",
                    Some(TileColor::White) => " .. ",
                    None                   => "    ",
                };
                s += &color_s;
            }
            if pos.x == self.idim {
                s += "\n\n";
            }
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
        Floor::from_input(&s)
    }

    /// Construct by reading tiles from input `lines`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line has an invalid format.
    pub fn from_input(lines: &str) -> Result<Floor> {
        let initial_tiles: Vec<Tile> = lines
            .trim()
            .split('\n')
            .map(str::parse)
            .collect::<Result<Vec<Tile>>>()?;
        let dim = Floor::dimension(&initial_tiles);
        let idim = i32::try_from(dim).unwrap();
        let colors: HashMap<i64, TileColor> = HashMap::new();
        Ok(Self { dim, idim, initial_tiles, colors })
    }

    // Returns the floor dimension (size), defined by the maximum
    // absolute-value y or x coordinate seen when following any of the
    // tile directions.
    #[must_use]
    fn dimension(initial_tiles: &[Tile]) -> usize {
        initial_tiles
            .iter()
            .fold(0, |d, tile| {
                let tile_maxes = tile.max_yx();
                cmp::max(cmp::max(d, tile_maxes.0), tile_maxes.1)
            })
    }

    /// Return iterator which returns all positions for a hex of the given
    /// `dim`.
    #[must_use]
    fn iter(&self, dim: usize) -> PosIter {
        let idim = i32::try_from(dim).unwrap();
        PosIter {
            idim,
            pos: Pos::new(-idim, -idim),
        }
    }

    // Return non-clipping iterator which returns all positions for a hex
    // parallelogram of the given `dim`.
    #[must_use]
    fn nonclip_iter(&self, dim: usize) -> NonClipPosIter {
        let idim = i32::try_from(dim).unwrap();
        NonClipPosIter {
            idim,
            pos: Pos::new(-idim, -idim),
        }
    }

    /// Flip tiles found by following tile directions.
    pub fn set_initial_tiles(&mut self) {
        self.fill();
        let poses: Vec<Pos> = self.initial_tiles
            .iter()
            .map(|tile| tile.pos)
            .collect();
        for pos in poses {
            self.flip_tile_at(pos);
        }
    }

    /// Return color of the tile at `pos`, or `None` if the position is
    /// outside the current floor bounds.
    #[must_use]
    pub fn color_at(&self, pos: Pos) -> Option<TileColor> {
        let key = pos.key();
        if let Some(&color) = self.colors.get(&key) {
            Some(color)
        } else {
            None
        }
    }

    // Flip the tile at `pos`. Does nothing if the position is outside the
    // current floor bounds.
    fn flip_tile_at(&mut self, pos: Pos) {
        let key = pos.key();
        if self.colors.contains_key(&key) {
            self.colors.insert(key, TileColor::opposite(self.colors[&key]));
        }
    }

    // Fill floor with white tiles, up to its calculated dimensions
    // (based on all tile directions).
    fn fill(&mut self) {
        for pos in self.iter(self.dim) {
            self.colors.insert(pos.key(), TileColor::White);
        }
    }

    /// How many tiles are black?
    #[must_use]
    pub fn n_black(&self) -> usize {
        self.colors
            .values()
            .filter(|&c| *c == TileColor::Black)
            .count()
    }

//    /// Do one round of tile-flipping, according to the puzzle description.
//    pub fn flip_tiles(&mut self) {
//        let mut flip_keys: Vec<i64> = vec![];
//        // FIXME merge with duplicate code in fill() - make an iterator
//        let dim_y = i32::try_from(self.dim).unwrap();
//        let dim_x = dim_y;
//        for y in -dim_y..=dim_y {
//            for x in -dim_x..=dim_x {
//                if y == 0 && x == 0 { continue; }
//                // without these two lines you get a parallelogram;
//                // we only want our 6 hexagonal neighbors
//                if y == -dim_y && x == -dim_x { continue; }
//                if y == dim_y && x == dim_x { continue; }
//                let pos = Pos::new(y, x);
//                let key = pos.key();
//                //eprintln!("...trying K{} for ({}, {})", key, pos.y, pos.x);
//                let color = self.colors[&key];
//                let n_black = self.n_neighbor_black(pos);
//                //eprintln!("{:?} at ({}, {}) (K{}) found {} black neighbors", color, y, x, key, n_black);
//                match (color, n_black) {
//                    (TileColor::Black, n) if n == 0 || n > 2 => flip_keys.push(key),
//                    (TileColor::White, n) if n == 2          => flip_keys.push(key),
//                    _                                        => { },
//                }
//            }
//        }
//        for key in flip_keys {
//            //eprintln!("flip K{}", key);
//            self.colors.insert(key, TileColor::opposite(self.colors[&key]));
//        }
//    }
//
//    fn n_neighbor_black(&self, pos: Pos) -> usize {
//        let mut neighbors: Vec<TileColor> = vec![];
//        for dy in -1..=1 {
//            for dx in -1..=1 {
//                if dy == 0 && dx == 0 { continue; }
//                // without these two lines you get a parallelogram;
//                // we only want our 6 hexagonal neighbors
//                if dy == -1 && dx == -1 { continue; }
//                if dy == 1 && dx == 1 { continue; }
//                let dpos = Pos::new(y + dy, x + dx);
//                if let Some(color) = self.colors.get(&dpos) {
//                    neighbors.push(*color);
//                }
//            }
//        }
//        neighbors.iter().filter(|&c| *c == TileColor::Black).count()
//    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // esenee identifies the tile you land on if you start at the reference tile and then move one
    // tile east, one tile southeast, one tile northeast, and one tile east

    #[test]
    fn test_parse_dir() {
        let dir: Pos = "sw".parse().unwrap();
        assert_eq!(Pos::new(1, -1), dir);
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
        assert_eq!(Pos::new(0, 3), Pos::sum(&tile.dirs));
        assert_eq!((1, 3), tile.max_yx());
    }

    #[test]
    fn test_parse_tile_2() {
        let tile: Tile = "esew".parse().unwrap();
        assert_eq!(vec![Pos::E, Pos::SE, Pos::W], tile.dirs);
        assert_eq!(Pos::new(1, 0), Pos::sum(&tile.dirs));
        assert_eq!((1, 1), tile.max_yx());
    }

    #[test]
    fn test_parse_tile_3() {
        let tile: Tile = "nwwswee".parse().unwrap();
        assert_eq!(vec![Pos::NW, Pos::W, Pos::SW, Pos::E, Pos::E], tile.dirs);
        assert_eq!(Pos::new(0, 0), Pos::sum(&tile.dirs));
        assert_eq!((1, 2), tile.max_yx());  // -1, -2
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
        assert_eq!(6, floor.dim);
        assert_eq!(20, floor.initial_tiles.len());
        assert_eq!(vec![
            Pos::SE, Pos::SE, Pos::NW, Pos::NE, Pos::NE,
            Pos::NE, Pos::W, Pos::SE, Pos::E, Pos::SW,
        ], &floor.initial_tiles[0].dirs[0..10]);
    }

    #[test]
    fn test_n_black() {
        let mut floor = Floor::read_from_file("input/example1.txt").unwrap();
        floor.set_initial_tiles();
        assert_eq!(10, floor.n_black());
    }

    #[test]
    fn test_floor_fill() {
        let lines = "esenee\nesew\nnwwswee\n".to_string();
        let mut floor = Floor::from_input(&lines).unwrap();
        assert_eq!(3, floor.dim);
        floor.fill();
        assert_eq!(4*2 + 5*2 + 6*2 + 7, floor.colors.len());
    }

    // Day 1: 15
    // Day 2: 12
    // Day 3: 25
    // Day 4: 14
    // Day 5: 23
    // Day 6: 28
    // Day 7: 41
    // Day 8: 37
    // Day 9: 49
    // Day 10: 37
    //
    // Day 20: 132
    // Day 30: 259
    // Day 40: 406
    // Day 50: 566
    // Day 60: 788
    // Day 70: 1106
    // Day 80: 1373
    // Day 90: 1844
    // Day 100: 2208
    //
//    #[test]
//    fn test_flip_tiles() {
//        let mut floor = Floor::read_from_file("input/example1.txt").unwrap();
//        floor.set_initial_tiles();
//        assert_eq!(10, floor.n_black());
//        for _ in 1..=1 {
//            floor.flip_tiles();
//        }
//        eprintln!("Day 1\n\n{}\n", floor);
//        assert_eq!(15, floor.n_black());
//        for _ in 2..=2 {
//            floor.flip_tiles();
//        }
//        eprintln!("Day 2\n\n{}\n", floor);
//        assert_eq!(12, floor.n_black());
//    }
//
//    #[test]
//    fn test_flip_tiles_small() {
//        let lines = "esenee\nesew\nnwwswee\n".to_string();
//        let mut floor = Floor::from_input(&lines).unwrap();
//        floor.set_initial_tiles();
//        eprintln!("INITIAL\n\n{}\n", floor);
//        assert_eq!(3, floor.n_black());
//        floor.flip_tiles();
//        eprintln!("MOVE 1\n\n{}\n", floor);
//        assert_eq!(4, floor.n_black());
//    }

    #[test]
    fn test_color_at() {
        let lines = "esenee\nesew\nnwwswee\n".to_string();
        let mut floor = Floor::from_input(&lines).unwrap();
        assert_eq!(3, floor.dim);
        floor.set_initial_tiles();
        //
        assert_eq!(Some(TileColor::Black), floor.color_at(Pos::new(0, 0)));
        assert_eq!(Some(TileColor::Black), floor.color_at(Pos::new(1, 0)));
        assert_eq!(Some(TileColor::Black), floor.color_at(Pos::new(0, 3)));
        assert_eq!(3, floor.n_black());
        //
        assert_eq!(Some(TileColor::White), floor.color_at(Pos::new(-3, 0)));
        assert_eq!(Some(TileColor::White), floor.color_at(Pos::new(-3, 3)));
        assert_eq!(Some(TileColor::White), floor.color_at(Pos::new(-1, -2)));
        assert_eq!(Some(TileColor::White), floor.color_at(Pos::new(0, -3)));
        assert_eq!(Some(TileColor::White), floor.color_at(Pos::new(1, 2)));
        assert_eq!(Some(TileColor::White), floor.color_at(Pos::new(3, 0)));
        //
        assert_eq!(None, floor.color_at(Pos::new(-3, -1)));
        assert_eq!(None, floor.color_at(Pos::new(-1, -3)));
        assert_eq!(None, floor.color_at(Pos::new(1, 3)));
        assert_eq!(None, floor.color_at(Pos::new(3, 1)));
    }

    #[test]
    fn test_pos_clip() {
        assert_eq!(false, Pos::new(-3, 0).clip(3));
        assert_eq!(false, Pos::new(-3, 3).clip(3));
        assert_eq!(false, Pos::new(-1, -2).clip(3));
        assert_eq!(false, Pos::new(0, -3).clip(3));
        assert_eq!(false, Pos::new(0, 0).clip(3));
        assert_eq!(false, Pos::new(0, 3).clip(3));
        assert_eq!(false, Pos::new(1, 0).clip(3));
        assert_eq!(false, Pos::new(1, 2).clip(3));
        assert_eq!(false, Pos::new(3, -3).clip(3));
        assert_eq!(false, Pos::new(3, 0).clip(3));
        //
        assert_eq!(true, Pos::new(-3, -1).clip(3));
        assert_eq!(true, Pos::new(-2, -2).clip(3));
        assert_eq!(true, Pos::new(-1, -3).clip(3));
        assert_eq!(true, Pos::new(1, 3).clip(3));
        assert_eq!(true, Pos::new(2, 2).clip(3));
        assert_eq!(true, Pos::new(3, 1).clip(3));
    }

    #[test]
    fn test_non_clip_pos_iter() {
        let lines = "esew\n".to_string();
        let floor = Floor::from_input(&lines).unwrap();
        assert_eq!(1, floor.dim);
        let mut i: NonClipPosIter = floor.nonclip_iter(floor.dim);
        assert_eq!(Some(Pos::new(-1, -1)), i.next());
        assert_eq!(Some(Pos::new(-1, 0)), i.next());
        assert_eq!(Some(Pos::new(-1, 1)), i.next());
        assert_eq!(Some(Pos::new(0, -1)), i.next());
        assert_eq!(Some(Pos::new(0, 0)), i.next());
        assert_eq!(Some(Pos::new(0, 1)), i.next());
        assert_eq!(Some(Pos::new(1, -1)), i.next());
        assert_eq!(Some(Pos::new(1, 0)), i.next());
        assert_eq!(Some(Pos::new(1, 1)), i.next());
        assert_eq!(None, i.next());
        assert_eq!(None, i.next());
        assert_eq!(None, i.next());
        assert_eq!(None, i.next());
    }
}
