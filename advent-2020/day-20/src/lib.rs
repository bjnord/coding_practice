#[macro_use] extern crate scan_fmt;

use custom_error::custom_error;
use std::collections::{HashMap, HashSet};
use std::convert::TryFrom;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub TileError
    GridNotFound = "tile grid not found",
    InvalidLine{line: String} = "invalid tile grid line [{line}]",
    InvalidPixel{pixel: char} = "invalid pixel character {pixel}",
    NotSquare = "tile is not square",
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Pixel(bool);

impl Pixel {
    /// Construct pixel from input character.
    #[must_use]
    pub fn from_char(pixel: char) -> Result<Pixel> {
        match pixel {
            '.' => Ok(Pixel(false)),
            '#' => Ok(Pixel(true)),
            _ => Err(TileError::InvalidPixel { pixel }.into())
        }
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Orientation {
    rotate: bool,  // 90 degrees
    flip_y: bool,
    flip_x: bool,
}

impl fmt::Display for Orientation {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut ss: Vec<&str> = vec![];
        if self.rotate { ss.push("Rot90") } else { ss.push("Rot0") }
        if self.flip_y { ss.push("FlipY") }
        if self.flip_x { ss.push("FlipX") }
        let label = ss.join(" ");
        write!(f, "{}", label)
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum BorderKind {
    Top,
    Right,
    Bottom,
    Left,
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Border {
    tile_id: u32,
    orientation: Orientation,
    kind: BorderKind,
    edge: usize,
    pattern: u32,
}

impl fmt::Display for Border {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let kind = match self.kind {
            BorderKind::Top => "Top",
            BorderKind::Right => "Right",
            BorderKind::Bottom => "Bottom",
            BorderKind::Left => "Left",
        };
        let display = format!("Tile {} - {} - {} {}",
            self.tile_id, self.orientation, kind,
            Border::pattern_string(self.pattern, self.edge));
        write!(f, "{}", display)
    }
}

impl Border {
    /// Return the four border kinds.
    pub fn kinds() -> Vec<BorderKind> {
        vec![
            BorderKind::Top,
            BorderKind::Right,
            BorderKind::Bottom,
            BorderKind::Left,
        ]
    }

    pub fn pattern_string(pattern: u32, edge: usize) -> String {
        (0..edge)
            .map(|i| {
                let pos: u32 = u32::try_from(edge - 1 - i).unwrap();
                let bit: u32 = u32::try_from(2_i32.pow(pos)).unwrap();
                if pattern & bit == 0 { '.' } else { '#' }
            })
            .collect()
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Tile {
    id: u32,
    pixels: Vec<Pixel>,
    edge: usize,
}

impl FromStr for Tile {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let mut i = input.lines();
        let label = i.next().unwrap();
        let (tile, id) = scan_fmt!(label, "{s} {d}", String, u32)?;
        if tile != "Tile" {
            return Err(TileError::InvalidLine { line: label.to_string() }.into());
        }
        let edge = i.next()
            .ok_or_else(|| TileError::GridNotFound)?
            .len();
        let pixels: Vec<Pixel> = input
            .lines()
            .skip(1)
            .flat_map(|line| line.trim().chars().map(Pixel::from_char))
            .collect::<Result<Vec<Pixel>>>()?;
        let height = pixels.len() / edge;
        if height != edge {
            return Err(TileError::NotSquare.into());
        }
        Ok(Self { id, pixels, edge })
    }
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        let label = format!("Tile {}:\n", self.id);
        s += &label;
        for y in 0..self.edge {
            for x in 0..self.edge {
                s += match self.pixel_at(y, x) {
                    false => ".",
                    true => "#",
                };
            }
            s += "\n";
        }
        write!(f, "{}", s)
    }
}

impl Tile {
    /// Construct by reading tiles from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if a line is
    /// found with an invalid integer format.
    pub fn read_from_file(path: &str) -> Result<Vec<Tile>> {
        let s: String = fs::read_to_string(path)?;
        s.trim().split("\n\n").map(str::parse).collect()
    }

    /// Return `Pixel` at (y, x).
    #[must_use]
    pub fn pixel_at(&self, y: usize, x: usize) -> bool {
        self.pixels[self.pixels_index(y, x)].0
    }

    fn pixels_index(&self, y: usize, x: usize) -> usize {
        y * self.edge + x
    }

    // all the possible tile orientations
    const ORI_ROT0: Orientation = Orientation { rotate: false, flip_y: false, flip_x: false };
    const ORI_ROT90: Orientation = Orientation { rotate: true, flip_y: false, flip_x: false };
    const ORI_ROT0_FLIPY: Orientation = Orientation { rotate: false, flip_y: true, flip_x: false };
    const ORI_ROT90_FLIPY: Orientation = Orientation { rotate: true, flip_y: true, flip_x: false };
    // ORI_FLIPY_ROT90 is the same as ORI_ROT90_FLIPX
    //const ORI_FLIPY_ROT90: Orientation = Orientation { rotate: true, flip_y: true, flip_x: false };
    const ORI_ROT0_FLIPX: Orientation = Orientation { rotate: false, flip_y: false, flip_x: true };
    const ORI_ROT90_FLIPX: Orientation = Orientation { rotate: true, flip_y: false, flip_x: true };
    // ORI_FLIPX_ROT90 is the same as ORI_ROT90_FLIPY
    //const ORI_FLIPX_ROT90: Orientation = Orientation { rotate: true, flip_y: false, flip_x: true };
    const ORI_ROT0_FLIPXY: Orientation = Orientation { rotate: false, flip_y: true, flip_x: true };
    const ORI_ROT90_FLIPXY: Orientation = Orientation { rotate: true, flip_y: true, flip_x: true };
    // ORI_FLIPXY_ROT90 is the same as ORI_ROT90_FLIPXY
    //const ORI_FLIPXY_ROT90: Orientation = Orientation { rotate: true, flip_y: true, flip_x: true };

    /// Return borders from all possible orientations of this tile.
    pub fn borders(&self) -> Vec<Border> {
        let orientations: Vec<Orientation> = vec![
            Tile::ORI_ROT0, Tile::ORI_ROT90,
            Tile::ORI_ROT0_FLIPY, Tile::ORI_ROT90_FLIPY, Tile::ORI_ROT0_FLIPX,
            Tile::ORI_ROT90_FLIPX, Tile::ORI_ROT0_FLIPXY, Tile::ORI_ROT90_FLIPXY,
        ];
        orientations
            .iter()
            .map(|&ori| self.borders_for_orientation(ori))
            .flatten()
            .collect::<Vec<Border>>()
    }

    /// Return borders from provided `orientation` of this tile.
    pub fn borders_for_orientation(&self, orientation: Orientation) -> Vec<Border> {
        let naturals = self.naturals();
        self.borders_of(orientation, &naturals)
    }

    fn borders_of(&self, orientation: Orientation, naturals: &Vec<u32>) -> Vec<Border> {
        let mut patterns: Vec<u32> = naturals.iter().copied().collect();
        if orientation.rotate {
            patterns = vec![
                Tile::invert(patterns[3], self.edge),
                patterns[0],
                Tile::invert(patterns[1], self.edge),
                patterns[2],
            ];
        }
        let mut flip_patterns: Vec<u32> = vec![0; 4];
        match (orientation.flip_y, orientation.flip_x) {
            (false, false) => {
                flip_patterns = patterns.iter().copied().collect();
            },
            (true, false) => {
                flip_patterns[0] = patterns[2];
                flip_patterns[1] = Tile::invert(patterns[1], self.edge);
                flip_patterns[2] = patterns[0];
                flip_patterns[3] = Tile::invert(patterns[3], self.edge);
            },
            (false, true) => {
                flip_patterns[0] = Tile::invert(patterns[0], self.edge);
                flip_patterns[1] = patterns[3];
                flip_patterns[2] = Tile::invert(patterns[2], self.edge);
                flip_patterns[3] = patterns[1];
            },
            (true, true) => {
                flip_patterns[0] = Tile::invert(patterns[2], self.edge);
                flip_patterns[1] = Tile::invert(patterns[3], self.edge);
                flip_patterns[2] = Tile::invert(patterns[0], self.edge);
                flip_patterns[3] = Tile::invert(patterns[1], self.edge);
            },
        }
        let top = Border { tile_id: self.id, orientation, kind: BorderKind::Top, edge: self.edge, pattern: flip_patterns[0] };
        let right = Border { tile_id: self.id, orientation, kind: BorderKind::Right, edge: self.edge, pattern: flip_patterns[1] };
        let bottom = Border { tile_id: self.id, orientation, kind: BorderKind::Bottom, edge: self.edge, pattern: flip_patterns[2] };
        let left = Border { tile_id: self.id, orientation, kind: BorderKind::Left, edge: self.edge, pattern: flip_patterns[3] };
        vec![top, right, bottom, left]
    }

    fn naturals(&self) -> Vec<u32> {
        Border::kinds()
            .iter()
            .map(|&kind| self.pattern_for(kind))
            .collect()
    }

    /// Return border pattern for the given tile edge (`kind`).
    pub fn pattern_for(&self, kind: BorderKind) -> u32 {
        let mut pattern: u32 = 0;
        for i in 0..self.edge {
            match kind {
                BorderKind::Top => pattern |= self.bit_at(0, i, i),
                BorderKind::Right => pattern |= self.bit_at(i, self.edge - 1, i),
                BorderKind::Bottom => pattern |= self.bit_at(self.edge - 1, i, i),
                BorderKind::Left => pattern |= self.bit_at(i, 0, i),
            }
        }
        pattern
    }

    fn bit_at(&self, y: usize, x: usize, i: usize) -> u32 {
        if self.pixel_at(y, x) {
            let pos: u32 = u32::try_from(self.edge - 1 - i).unwrap();
            u32::try_from(2_i32.pow(pos)).unwrap()
        } else {
            0
        }
    }

    fn invert(pattern: u32, edge: usize) -> u32 {
        let mut inv_pattern: u32 = 0;
        for i in 0..edge {
            let pos = u32::try_from(edge - 1 - i).unwrap();
            let inv_pos = u32::try_from(i).unwrap();
            let bit = u32::try_from(2_i32.pow(pos)).unwrap();
            let inv_bit = u32::try_from(2_i32.pow(inv_pos)).unwrap();
            if pattern & bit != 0 {
                inv_pattern |= inv_bit;
            }
        }
        inv_pattern
    }

    /// Find tile orientations and positions such that edges line up.
    pub fn solve(tiles: &Vec<Tile>) -> u64 {
        let mut aboves: Vec<u32> = vec![];
        let mut right_ofs: Vec<u32> = vec![];
        let mut belows: Vec<u32> = vec![];
        let mut left_ofs: Vec<u32> = vec![];
        let border_count = tiles.len() * 4;
        let mut blacklist: HashSet<String> = HashSet::new();
        for _n in 0..border_count {
            let mut orientation: HashMap<u32, Orientation> = HashMap::new();
            let mut above: HashMap<u32, u32> = HashMap::new();
            let mut right_of: HashMap<u32, u32> = HashMap::new();
            let mut below: HashMap<u32, u32> = HashMap::new();
            let mut left_of: HashMap<u32, u32> = HashMap::new();
            // FIXME change this to `used_border` and use it for 1ST<->2ND match too
            //       will simplify the first.iter().find() quite a bit
            let mut border_edge: HashSet<String> = HashSet::new();
            let mut first_used_border: Option<Border> = None;
            for _x in 0..border_count {
                let borders: Vec<Border> = tiles
                    .iter()
                    .map(|tile| {
                        if orientation.contains_key(&tile.id) {
                            tile.borders_for_orientation(orientation[&tile.id])
                        } else {
                            tile.borders()
                        }
                    })
                    .flatten()
                    .collect();
                //eprintln!("----{} BORDERS----{}:{}----", borders.len(), n, x);
                let first = borders
                    .iter()
                    .find(|bord|
                        !(above.contains_key(&bord.tile_id) && bord.kind == BorderKind::Top)
                        &&
                        !(right_of.contains_key(&bord.tile_id) && bord.kind == BorderKind::Right)
                        &&
                        !(below.contains_key(&bord.tile_id) && bord.kind == BorderKind::Bottom)
                        &&
                        !(left_of.contains_key(&bord.tile_id) && bord.kind == BorderKind::Left)
                        &&
                        !border_edge.contains(&Tile::edge_key(bord))
                        &&
                        !blacklist.contains(&Tile::edge_key(bord))
                    );
                if first.is_none() {
                    //eprintln!("NO 1ST -- try again; blacklist {}", first_used_border.unwrap());
                    blacklist.insert(Tile::edge_key(&first_used_border.unwrap()));
                    // aboves
                    let new_aboves: Vec<u32> = above.values().copied().collect();
                    //eprintln!("aboves = {:?}  new_aboves = {:?}", aboves, new_aboves);
                    if new_aboves.len() > aboves.len() {
                        //eprintln!("--> replace A");
                        aboves = new_aboves;
                    }
                    // right_ofs
                    let new_right_ofs: Vec<u32> = right_of.values().copied().collect();
                    //eprintln!("right_ofs = {:?}  new_right_ofs = {:?}", right_ofs, new_right_ofs);
                    if new_right_ofs.len() > right_ofs.len() {
                        //eprintln!("--> replace R");
                        right_ofs = new_right_ofs;
                    }
                    // belows
                    let new_belows: Vec<u32> = below.values().copied().collect();
                    //eprintln!("belows = {:?}  new_belows = {:?}", belows, new_belows);
                    if new_belows.len() > belows.len() {
                        //eprintln!("--> replace B");
                        belows = new_belows;
                    }
                    // left_ofs
                    let new_left_ofs: Vec<u32> = left_of.values().copied().collect();
                    //eprintln!("left_ofs = {:?}  new_left_ofs = {:?}", left_ofs, new_left_ofs);
                    if new_left_ofs.len() > left_ofs.len() {
                        //eprintln!("--> replace L");
                        left_ofs = new_left_ofs;
                    }
                    break;
                }
                let first = first.unwrap();
                if first_used_border.is_none() {
                    first_used_border = Some(*first);
                }
                //eprintln!("1ST {}", first);
                let second_kind = Tile::opposite_kind(first.kind);
                let mut second_borders: Vec<&Border> = borders
                    .iter()
                    .filter(|bord|
                        bord.tile_id != first.tile_id &&
                        bord.kind == second_kind &&
                        bord.pattern == first.pattern
                    )
                    .collect();
                let mut pattern_count: HashMap<u32, usize> = HashMap::new();
                for bord in second_borders.iter() {
                    *pattern_count.entry(bord.pattern).or_insert(0) += 1;
                }
                second_borders.sort_by(|a, b| {
                    // first by lowest pattern cmp, then by the pattern itself
                    let count_cmp = pattern_count[&a.pattern].cmp(&pattern_count[&b.pattern]);
                    if count_cmp == std::cmp::Ordering::Equal {
                        a.pattern.cmp(&b.pattern)
                    } else {
                        count_cmp
                    }
                });
                let second = second_borders.iter().next();
                if second.is_some() {
                    let second = second.unwrap();
                    //eprintln!("2ND {} (count={})", second, pattern_count[&second.pattern]);
                    orientation.insert(first.tile_id, first.orientation);
                    orientation.insert(second.tile_id, second.orientation);
                    match first.kind {
                        BorderKind::Top => { above.insert(first.tile_id, second.tile_id); },
                        BorderKind::Right => { right_of.insert(first.tile_id, second.tile_id); },
                        BorderKind::Bottom => { below.insert(first.tile_id, second.tile_id); },
                        BorderKind::Left => { left_of.insert(first.tile_id, second.tile_id); },
                    }
                    match second.kind {
                        BorderKind::Top => { above.insert(second.tile_id, first.tile_id); },
                        BorderKind::Right => { right_of.insert(second.tile_id, first.tile_id); },
                        BorderKind::Bottom => { below.insert(second.tile_id, first.tile_id); },
                        BorderKind::Left => { left_of.insert(second.tile_id, first.tile_id); },
                    }
                } else {
                    //eprintln!("1ST is EDGE border");
                    border_edge.insert(Tile::edge_key(first));
                }
                //eprintln!("^^^^^ above = {:?}", above);
                //eprintln!(">>>>> right_of = {:?}", right_of);
                //eprintln!("vvvvv below = {:?}", below);
                //eprintln!("<<<<< left_of = {:?}", left_of);
            }
        }
        let mut corners: u64 = 1;
        // --------------------------------------
        let top_left = tiles
            .iter()
            .find(|tile|
                !aboves.iter().any(|&id| id == tile.id) && !left_ofs.iter().any(|&id| id == tile.id)
                && belows.iter().any(|&id| id == tile.id) && right_ofs.iter().any(|&id| id == tile.id)
            )
            .unwrap();
        eprintln!("TOP LEFT = ID {}", top_left.id);
        corners *= top_left.id as u64;
        // --------------------------------------
        let top_right = tiles
            .iter()
            .find(|tile|
                !aboves.iter().any(|&id| id == tile.id) && left_ofs.iter().any(|&id| id == tile.id)
                && belows.iter().any(|&id| id == tile.id) && !right_ofs.iter().any(|&id| id == tile.id)
            )
            .unwrap();
        eprintln!("TOP RIGHT = ID {}", top_right.id);
        corners *= top_right.id as u64;
        // --------------------------------------
        let bottom_left = tiles
            .iter()
            .find(|tile|
                aboves.iter().any(|&id| id == tile.id) && !left_ofs.iter().any(|&id| id == tile.id)
                && !belows.iter().any(|&id| id == tile.id) && right_ofs.iter().any(|&id| id == tile.id)
            )
            .unwrap();
        eprintln!("BOTTOM LEFT = ID {}", bottom_left.id);
        corners *= bottom_left.id as u64;
        // --------------------------------------
        let bottom_right = tiles
            .iter()
            .find(|tile|
                aboves.iter().any(|&id| id == tile.id) && left_ofs.iter().any(|&id| id == tile.id)
                && !belows.iter().any(|&id| id == tile.id) && !right_ofs.iter().any(|&id| id == tile.id)
            )
            .unwrap();
        eprintln!("BOTTOM RIGHT = ID {}", bottom_right.id);
        corners *= bottom_right.id as u64;
        // --------------------------------------
        eprintln!("*** ANSWER {} ***", corners);
        corners
    }

    fn opposite_kind(kind: BorderKind) -> BorderKind {
        match kind {
            BorderKind::Top => BorderKind::Bottom,
            BorderKind::Right => BorderKind::Left,
            BorderKind::Bottom => BorderKind::Top,
            BorderKind::Left => BorderKind::Right,
        }
    }

    fn edge_key(border: &Border) -> String {
        format!("{}:{:?}", border.tile_id, border.kind)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const TINY_TILE: &'static str = "Tile 113:\n..#\n#..\n.##\n";

    #[test]
    fn test_parse_tile() {
        let tile: Tile = TINY_TILE.parse().unwrap();
        assert_eq!(113, tile.id);
        assert_eq!(3, tile.edge);
    }

    #[test]
    fn test_tile_indexing() {
        let tile: Tile = TINY_TILE.parse().unwrap();
        assert_eq!(true, tile.pixel_at(0, 2));
        assert_eq!(true, tile.pixel_at(1, 0));
        assert_eq!(false, tile.pixel_at(1, 1));
        assert_eq!(false, tile.pixel_at(2, 0));
        assert_eq!(false, tile.pixel_at(0, 1));
    }

    #[test]
    fn test_read_from_file_no_file() {
        match Tile::read_from_file("input/example99.txt") {
            Err(e) => assert!(e.to_string().contains("No such file")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_no_grid() {
        if let Err(_e) = Tile::read_from_file("input/bad1.txt") {
            //assert_eq!(TileError::GridNotFound, *e);
            assert!(true);  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_read_from_file_invalid_line() {
        if let Err(_e) = Tile::read_from_file("input/bad2.txt") {
            //assert_eq!(TileError::InvalidLine { line: "Spile 12:" }, *e);
            assert!(true);  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_read_from_file_not_square() {
        if let Err(_e) = Tile::read_from_file("input/bad3.txt") {
            //assert_eq!(TileError::NotSquare, *e);
            assert!(true);  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_pixel_from_char() {
        assert_eq!(Pixel(false), Pixel::from_char('.').unwrap());
        assert_eq!(Pixel(true), Pixel::from_char('#').unwrap());
    }

    #[test]
    fn test_pixel_from_char_invalid() {
        if let Err(_e) = Pixel::from_char('?') {
            //assert_eq!(TileError::InvalidPixel { pixel: '?' }, *e);
            assert!(true);  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_tile_borders_rot0() {
        let expect = vec!["...#.#.#.#", "#..#......", "#.##...##.", ".#....####"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90() {
        let expect = vec!["####....#.", "...#.#.#.#", "......#..#", "#.##...##."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot0_flipy() {
        let expect = vec!["#.##...##.", "......#..#", "...#.#.#.#", "####....#."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0_FLIPY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipy() {
        let expect = vec!["......#..#", "#.#.#.#...", "####....#.", ".##...##.#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90_FLIPY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    // ORI_ROT90_FLIPX is the same as ORI_FLIPY_ROT90
//    #[test]
//    fn test_tile_borders_flipy_rot90() {
//        let expect = vec![".#....####", "#.##...##.", "#..#......", "...#.#.#.#"];
//        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
//        let actual: Vec<String> = tile.borders_of(Tile::ORI_FLIPY_ROT90, &tile.naturals())
//            .iter()
//            .map(|border| Border::pattern_string(border.pattern, border.edge))
//            .collect();
//        assert_eq!(expect, actual);
//    }

    #[test]
    fn test_tile_borders_rot0_flipx() {
        let expect = vec!["#.#.#.#...", ".#....####", ".##...##.#", "#..#......"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0_FLIPX, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipx() {
        let expect = vec![".#....####", "#.##...##.", "#..#......", "...#.#.#.#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90_FLIPX, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    // ORI_FLIPX_ROT90 is the same as ORI_ROT90_FLIPY
//    #[test]
//    fn test_tile_borders_flipx_rot90() {
//        let expect = vec!["......#..#", "#.#.#.#...", "####....#.", ".##...##.#"];
//        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
//        let actual: Vec<String> = tile.borders_of(Tile::ORI_FLIPX_ROT90, &tile.naturals())
//            .iter()
//            .map(|border| Border::pattern_string(border.pattern, border.edge))
//            .collect();
//        assert_eq!(expect, actual);
//    }

    #[test]
    fn test_tile_borders_rot0_flipxy() {
        let expect = vec![".##...##.#", "####....#.", "#.#.#.#...", "......#..#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0_FLIPXY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipxy() {
        let expect = vec!["#..#......", ".##...##.#", ".#....####", "#.#.#.#..."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90_FLIPXY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    // ORI_FLIPXY_ROT90 is the same as ORI_ROT90_FLIPXY
//    #[test]
//    fn test_tile_borders_flipxy_rot90() {
//        let expect = vec!["#..#......", ".##...##.#", ".#....####", "#.#.#.#..."];
//        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
//        let actual: Vec<String> = tile.borders_of(Tile::ORI_FLIPXY_ROT90, &tile.naturals())
//            .iter()
//            .map(|border| Border::pattern_string(border.pattern, border.edge))
//            .collect();
//        assert_eq!(expect, actual);
//    }

    #[test]
    fn test_solve_example1() {
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        assert_eq!(20899048083289, Tile::solve(&tiles));
    }
}
