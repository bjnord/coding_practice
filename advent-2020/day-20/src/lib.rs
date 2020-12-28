#[macro_use] extern crate scan_fmt;

use custom_error::custom_error;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::fmt;
use std::fs;
use std::str::FromStr;

pub mod image;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub TileError
    GridNotFound = "tile grid not found",
    InvalidLine{line: String} = "invalid tile grid line [{line}]",
    InvalidPixel{pixel: char} = "invalid pixel character '{pixel}'",
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

    /// Return the opposite of the given border `kind`.
    pub fn opposite_kind(kind: BorderKind) -> BorderKind {
        match kind {
            BorderKind::Top => BorderKind::Bottom,
            BorderKind::Right => BorderKind::Left,
            BorderKind::Bottom => BorderKind::Top,
            BorderKind::Left => BorderKind::Right,
        }
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
                s += match self.pixel_at(Tile::ORI_ROT0, y, x) {
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

    /// Return pixel at (y, x) for the given `orientation`.
    #[must_use]
    pub fn pixel_at(&self, orientation: Orientation, y: usize, x: usize) -> bool {
        self.pixels[self.pixels_index(orientation, y, x)].0
    }

    fn pixels_index(&self, orientation: Orientation, y: usize, x: usize) -> usize {
        let mut yt: usize = y;
        let mut xt: usize = x;
        if orientation.rotate {
            yt = self.edge - 1 - x;
            xt = y;
        }
        if orientation.flip_y {
            if orientation.rotate {
                xt = self.edge - 1 - xt;
            } else {
                yt = self.edge - 1 - yt;
            }
        }
        if orientation.flip_x {
            if orientation.rotate {
                yt = self.edge - 1 - yt;
            } else {
                xt = self.edge - 1 - xt;
            }
        }
        yt * self.edge + xt
    }

    // all the possible tile orientations
    const ORI_ROT0: Orientation = Orientation { rotate: false, flip_y: false, flip_x: false };
    const ORI_ROT90: Orientation = Orientation { rotate: true, flip_y: false, flip_x: false };
    const ORI_ROT0_FLIPY: Orientation = Orientation { rotate: false, flip_y: true, flip_x: false };
    const ORI_ROT90_FLIPY: Orientation = Orientation { rotate: true, flip_y: true, flip_x: false };
    const ORI_ROT0_FLIPX: Orientation = Orientation { rotate: false, flip_y: false, flip_x: true };
    const ORI_ROT90_FLIPX: Orientation = Orientation { rotate: true, flip_y: false, flip_x: true };
    const ORI_ROT0_FLIPXY: Orientation = Orientation { rotate: false, flip_y: true, flip_x: true };
    const ORI_ROT90_FLIPXY: Orientation = Orientation { rotate: true, flip_y: true, flip_x: true };

    /// Return borders from all possible orientations of this tile.
    pub fn borders(&self) -> Vec<Border> {
        let orientations: Vec<Orientation> = vec![
            Tile::ORI_ROT0, Tile::ORI_ROT90,
            Tile::ORI_ROT0_FLIPY, Tile::ORI_ROT90_FLIPY, Tile::ORI_ROT0_FLIPX,
            Tile::ORI_ROT90_FLIPX, Tile::ORI_ROT0_FLIPXY, Tile::ORI_ROT90_FLIPXY,
        ];
        orientations
            .iter()
            .map(|&ori| self.borders_for(ori))
            .flatten()
            .collect::<Vec<Border>>()
    }

    /// Return borders from provided `orientation` of this tile.
    pub fn borders_for(&self, orientation: Orientation) -> Vec<Border> {
        Border::kinds()
            .iter()
            .map(|&kind| Border {
                tile_id: self.id,
                orientation,
                kind,
                edge: self.edge,
                pattern: self.pattern_for(orientation, kind),
            })
            .collect()
    }

    /// Return border pattern for the given tile edge (`kind`) and `orientation`.
    pub fn pattern_for(&self, orientation: Orientation, kind: BorderKind) -> u32 {
        let mut pattern: u32 = 0;
        for i in 0..self.edge {
            pattern |= match kind {
                BorderKind::Top =>
                    self.bit_at(orientation, 0, i, i),
                BorderKind::Right =>
                    self.bit_at(orientation, i, self.edge - 1, i),
                BorderKind::Bottom =>
                    self.bit_at(orientation, self.edge - 1, i, i),
                BorderKind::Left =>
                    self.bit_at(orientation, i, 0, i),
            }
        }
        pattern
    }

    fn bit_at(&self, orientation: Orientation, y: usize, x: usize, i: usize) -> u32 {
        if self.pixel_at(orientation, y, x) {
            let pos: u32 = u32::try_from(self.edge - 1 - i).unwrap();
            u32::try_from(2_i32.pow(pos)).unwrap()
        } else {
            0
        }
    }

    /// Return product of the four corner tiles.
    pub fn neosolve(tiles: &Vec<Tile>) -> u64 {
        let borders = Tile::all_borders(&tiles);
        //eprintln!("#borders = {}", borders.len());
        Tile::corner_tile_ids(tiles, &borders, BorderKind::Top)
            .iter()
            .map(|id| u64::try_from(*id).unwrap())
            .product()
    }

    fn all_borders(tiles: &Vec<Tile>) -> Vec<Border> {
        tiles
            .iter()
            .map(|tile| tile.borders())
            .flatten()
            .collect()
    }

    // Well this is embarrassing. While exploring possible ways to solve part
    // 1, I noticed a pattern in the following output, which just happened to
    // pinpoint the four corners. It works for my puzzle input and I have no
    // idea how. :D
    fn corner_tile_ids(tiles: &Vec<Tile>, borders: &Vec<Border>, kind: BorderKind) -> Vec<u32> {
        let mut corner_tile_ids: Vec<u32> = vec![];
        let kind_borders: Vec<&Border> = borders
            .iter()
            .filter(|bord| bord.kind == kind)
            .collect();
        //eprintln!("#kind_borders ({:?}) = {}", kind, kind_borders.len());
        for tile in tiles {
            let mut kind_pattern_count: HashMap<u32, usize> = HashMap::new();
            for bord in kind_borders.iter() {
                if bord.tile_id != tile.id {
                    *kind_pattern_count.entry(bord.pattern).or_insert(0) += 1;
                }
            }
            //eprintln!("not ID {} kind_pattern_count ({:?}) = {:?}", tile.id, kind, kind_pattern_count);
            let opp_kind = Border::opposite_kind(kind);
            let opp_kind_patterns: Vec<u32> = tile.borders()
                .iter()
                .filter(|bord| bord.kind == opp_kind && !kind_pattern_count.contains_key(&bord.pattern))
                .map(|bord| bord.pattern)
                .collect();
            //eprintln!("ID {} #opp_kind_patterns ({:?}) = {}", tile.id, opp_kind, opp_kind_patterns.len());
            if opp_kind_patterns.len() == 4 {
                corner_tile_ids.push(tile.id);
            }
        }
        //eprintln!("corner_tile_ids = {:?}", corner_tile_ids);
        corner_tile_ids
    }

    /// Return NxN matrix of Top Borders, describing the proper orientation
    /// of the given `tiles` so their inner edges align.
    pub fn aligned_borders(tiles: &Vec<Tile>) -> Vec<Vec<Border>> {
        ///////
        // this case is for testing:
        if tiles.len() == 1 {
            let border = Border {
                tile_id: 1,
                orientation: Tile::ORI_ROT0,
                kind: BorderKind::Top,
                edge: 10,
                pattern: 0x0,
            };
            return vec![vec![border]];
        }
        let edge = (tiles.len() as f64).sqrt() as usize;
        if edge * edge != tiles.len() {
            panic!("not square grid of tiles");
        }
        let borders = Tile::all_borders(&tiles);
        //eprintln!("edge={} tiles.len()={} borders.len()={}", edge, tiles.len(), borders.len());
        ///////
        // any of the 4 corners should work in upper-left position; use 1st:
        let corner_tile_id = Tile::corner_tile_ids(tiles, &borders, BorderKind::Top)[0];
        ///////
        // find Right borders of all 8 orientations of `corner_tile_id`, to
        // have 1st child match against:
        let corner_borders: Vec<Border> = borders
            .iter()
            .filter(|bord| bord.kind == BorderKind::Right && bord.tile_id == corner_tile_id)
            .copied()
            .collect();
        //eprintln!("corner_tile_id={} corner_borders.len()={} (should be 8)", corner_tile_id, corner_borders.len());
//        // FOR DEBUGGING: lock the first corner so input/example1.txt comes
//        // out as the puzzle description has it
//        corner_tile_id = 1951;
//        corner_borders = vec![*borders
//            .iter()
//            .find(|bord| bord.kind == BorderKind::Right && bord.tile_id == 1951 && bord.orientation == Tile::ORI_ROT0_FLIPY)
//            .unwrap()];
//        //eprintln!("corner_tile_id=1951 corner_borders.len()={} (should be 1)", corner_borders.len());
        ///////
        // call recursive function to find correct 1st child border:
        let remain_borders: Vec<Border> = borders
            .iter()
            .filter(|bord| bord.tile_id != corner_tile_id)
            .copied()
            .collect();
        //eprintln!("remain_borders.len()={} (should be {}-32)", remain_borders.len(), borders.len());
        let mut snaked_borders: Option<Vec<Border>> = None;
        for corner_border in corner_borders {
            let prior_borders = vec![corner_border];
            let borders = Tile::align_tile(edge, 1, &prior_borders, &remain_borders);
            if borders.is_some() {
                snaked_borders = borders;
                break;
            }
        }
        if snaked_borders.is_none() {
            panic!("SOLUTION NOT FOUND");
        }
        let snaked_borders: Vec<Border> = snaked_borders.unwrap();
        //for (i, s_bord) in snaked_borders.iter().enumerate() {
        //    eprintln!("{}: {}", i, s_bord);
        //}
        ///////
        // "de-snake" the results by flipping odd rows:
        let mut aligned_borders: Vec<Vec<Border>> = vec![];
        for y in 0..edge {
            aligned_borders.push(vec![]);
            for x in 0..edge {
                let odd = (y & 0x1) == 0x1;
                let x1 = if odd { edge - 1 - x } else { x };
                let i = y * edge + x1;
                //eprintln!("desnake odd? {} from ({}, {}) i={} to ({}, {})", odd, y, x1, i, y, x);
                aligned_borders[y].push(snaked_borders[i]);
            }
        }
        //for (y, a_bord_row) in aligned_borders.iter().enumerate() {
        //    for (x, a_bord) in a_bord_row.iter().enumerate() {
        //        eprintln!("({}, {}): {}", y, x, a_bord);
        //    }
        //}
        aligned_borders
    }

    fn align_tile(edge: usize, snake_i: usize, prior_borders: &Vec<Border>, remain_borders: &Vec<Border>) -> Option<Vec<Border>> {
        let parent_border = prior_borders.last().unwrap();
        //eprintln!("--recursive-- snake_i={} remain_borders.len()={} parent_border={}", snake_i, remain_borders.len(), parent_border);
        if snake_i >= edge * edge {
            //eprintln!("FOUND!");
            return Some(prior_borders.to_vec());
        }
        ///////
        // find tiles + orientations in which this tile lines up with parent:
        let match_borders: Vec<Border> = remain_borders
            .iter()
            .filter(|bord| bord.kind == Border::opposite_kind(parent_border.kind) &&
                bord.pattern == parent_border.pattern
            )
            .copied()
            .collect();
        //eprintln!("              match_borders.len()={} opp_parent_kind={:?}", match_borders.len(), Border::opposite_kind(parent_border.kind));
        ///////
        // compute border match kind for our place in the "snake":
        // - match right-to-left across the top (even) row
        // - match bottom-to-top for the last column
        // - match left-to-right back across the 2nd (odd) row
        // - match bottom-to-top for the first column, and repeat
        let next_snake_i = snake_i + 1;
        let y = next_snake_i / edge;
        let x = next_snake_i.rem_euclid(edge);
        let odd = (y & 0x1) == 0x1;
        let child_kind = if x == 0 { BorderKind::Bottom } else { if odd { BorderKind::Left } else { BorderKind::Right } };
        ///////
        // call recursive function to find correct next child border:
        let try_borders: Vec<Border> = remain_borders
            .iter()
            .filter(|bord| bord.kind == child_kind &&
                match_borders.iter().find(|m_bord| bord.tile_id == m_bord.tile_id && bord.orientation == m_bord.orientation).is_some()
            )
            .copied()
            .collect();
        //eprintln!("              ({}, {}, {}) try_borders.len()={} child_kind={:?}", y, x, odd, try_borders.len(), child_kind);
        let mut prior_borders = prior_borders.clone();
        for try_border in try_borders {
            prior_borders.push(try_border);
            let remain_borders: Vec<Border> = remain_borders
                .iter()
                .filter(|bord| bord.tile_id != try_border.tile_id)
                .copied()
                .collect();
            let borders = Tile::align_tile(edge, next_snake_i, &prior_borders, &remain_borders);
            prior_borders.pop();
            if borders.is_some() {
                return borders;
            }
        }
        None
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
        assert_eq!(true, tile.pixel_at(Tile::ORI_ROT0, 0, 2));
        assert_eq!(true, tile.pixel_at(Tile::ORI_ROT0, 1, 0));
        assert_eq!(false, tile.pixel_at(Tile::ORI_ROT0, 1, 1));
        assert_eq!(false, tile.pixel_at(Tile::ORI_ROT0, 2, 0));
        assert_eq!(false, tile.pixel_at(Tile::ORI_ROT0, 0, 1));
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
        match Tile::read_from_file("input/bad1.txt") {
            Err(e) => assert_eq!("tile grid not found", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_invalid_line() {
        match Tile::read_from_file("input/bad2.txt") {
            Err(e) => assert_eq!("invalid tile grid line [Spile 12:]", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_not_square() {
        match Tile::read_from_file("input/bad3.txt") {
            Err(e) => assert_eq!("tile is not square", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_pixel_from_char() {
        assert_eq!(Pixel(false), Pixel::from_char('.').unwrap());
        assert_eq!(Pixel(true), Pixel::from_char('#').unwrap());
    }

    #[test]
    fn test_pixel_from_char_invalid() {
        match Pixel::from_char('?') {
            Err(e) => assert_eq!("invalid pixel character '?'", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_tile_borders_rot0() {
        let expect = vec!["...#.#.#.#", "#..#......", "#.##...##.", ".#....####"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT0)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90() {
        let expect = vec!["####....#.", "...#.#.#.#", "......#..#", "#.##...##."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT90)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot0_flipy() {
        let expect = vec!["#.##...##.", "......#..#", "...#.#.#.#", "####....#."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT0_FLIPY)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipy() {
        let expect = vec!["......#..#", "#.#.#.#...", "####....#.", ".##...##.#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT90_FLIPY)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot0_flipx() {
        let expect = vec!["#.#.#.#...", ".#....####", ".##...##.#", "#..#......"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT0_FLIPX)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipx() {
        let expect = vec![".#....####", "#.##...##.", "#..#......", "...#.#.#.#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT90_FLIPX)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot0_flipxy() {
        let expect = vec![".##...##.#", "####....#.", "#.#.#.#...", "......#..#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT0_FLIPXY)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipxy() {
        let expect = vec!["#..#......", ".##...##.#", ".#....####", "#.#.#.#..."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_for(Tile::ORI_ROT90_FLIPXY)
            .iter()
            .map(|border| Border::pattern_string(border.pattern, border.edge))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_solve_example1() {
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        assert_eq!(20899048083289, Tile::neosolve(&tiles));
    }
}
