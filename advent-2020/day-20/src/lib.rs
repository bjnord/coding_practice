#[macro_use] extern crate scan_fmt;

use custom_error::custom_error;
use std::collections::HashMap;
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

    /// Find product of the four corner tiles
    pub fn neosolve(tiles: &Vec<Tile>) -> u64 {
        let borders: Vec<Border> = tiles
            .iter()
            .map(|tile| tile.borders())
            .flatten()
            .collect();
        //eprintln!("#borders = {}", borders.len());
        //for kind in Border::kinds() {
        //    let answer = Tile::corner_product(tiles, &borders, kind);
        //    eprintln!("answer ({:?}) = {}", kind, answer);
        //}
        // all 4 give the same answer, so just pick any one:
        Tile::corner_product(tiles, &borders, BorderKind::Top)
    }

    // Well this is embarrassing. While exploring possible ways to solve part
    // 1, I noticed a pattern in the following output, which just happened to
    // pinpoint the four corners. It works for my puzzle input and I have no
    // idea how. :D
    fn corner_product(tiles: &Vec<Tile>, borders: &Vec<Border>, kind: BorderKind) -> u64 {
        let mut corner_product: u64 = 1;
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
                corner_product *= tile.id as u64;
            }
        }
        corner_product
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

    // ORI_ROT90_FLIPX is the same as ORI_FLIPY_ROT90
//    #[test]
//    fn test_tile_borders_flipy_rot90() {
//        let expect = vec![".#....####", "#.##...##.", "#..#......", "...#.#.#.#"];
//        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
//        let actual: Vec<String> = tile.borders_for(Tile::ORI_FLIPY_ROT90)
//            .iter()
//            .map(|border| Border::pattern_string(border.pattern, border.edge))
//            .collect();
//        assert_eq!(expect, actual);
//    }

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

    // ORI_FLIPX_ROT90 is the same as ORI_ROT90_FLIPY
//    #[test]
//    fn test_tile_borders_flipx_rot90() {
//        let expect = vec!["......#..#", "#.#.#.#...", "####....#.", ".##...##.#"];
//        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
//        let actual: Vec<String> = tile.borders_for(Tile::ORI_FLIPX_ROT90)
//            .iter()
//            .map(|border| Border::pattern_string(border.pattern, border.edge))
//            .collect();
//        assert_eq!(expect, actual);
//    }

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

    // ORI_FLIPXY_ROT90 is the same as ORI_ROT90_FLIPXY
//    #[test]
//    fn test_tile_borders_flipxy_rot90() {
//        let expect = vec!["#..#......", ".##...##.#", ".#....####", "#.#.#.#..."];
//        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
//        let actual: Vec<String> = tile.borders_for(Tile::ORI_FLIPXY_ROT90)
//            .iter()
//            .map(|border| Border::pattern_string(border.pattern, border.edge))
//            .collect();
//        assert_eq!(expect, actual);
//    }

    #[test]
    fn test_solve_example1() {
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        assert_eq!(20899048083289, Tile::neosolve(&tiles));
    }
}
