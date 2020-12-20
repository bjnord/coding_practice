#[macro_use] extern crate scan_fmt;

use custom_error::custom_error;
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
    rotate_first: bool,
}

impl fmt::Display for Orientation {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut ss: Vec<&str> = vec![];
        if self.rotate_first {
            if self.rotate { ss.push("Rot90") } else { ss.push("Rot0") }
        }
        if self.flip_y { ss.push("FlipY") }
        if self.flip_x { ss.push("FlipX") }
        if !self.rotate_first {
            if self.rotate { ss.push("Rot90") } else { ss.push("Rot0") }
        }
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

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Border {
    tile_id: u32,
    orientation: Orientation,
    kind: BorderKind,
    pattern: u32,
}

// FIXME breaks our ability to support multiple tile sizes
const FIXED_WIDTH: usize = 10;

impl fmt::Display for Border {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let kind = match self.kind {
            BorderKind::Top => "Top",
            BorderKind::Right => "Right",
            BorderKind::Bottom => "Bottom",
            BorderKind::Left => "Left",
        };
        let display = format!("Tile {} - {} - {} {}", self.tile_id, self.orientation, kind, Border::pattern_string(self.pattern, FIXED_WIDTH));
        write!(f, "{}", display)
    }
}

impl Border {
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
    height: usize,
    width: usize,
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
        let width = i.next()
            .ok_or_else(|| TileError::GridNotFound)?
            .len();
        let pixels: Vec<Pixel> = input
            .lines()
            .skip(1)
            .flat_map(|line| line.trim().chars().map(Pixel::from_char))
            .collect::<Result<Vec<Pixel>>>()?;
        let height = pixels.len() / width;
        Ok(Self { id, pixels, height, width })
    }
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        let label = format!("Tile {}:\n", self.id);
        s += &label;
        for y in 0..self.height {
            for x in 0..self.width {
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
        y * self.width + x
    }

    // all the possible tile orientations
    // set `rotate_first: true` when not rotating, for display purposes
    const ORI_ROT0: Orientation = Orientation { rotate: false, flip_y: false, flip_x: false, rotate_first: true };
    const ORI_ROT90: Orientation = Orientation { rotate: true, flip_y: false, flip_x: false, rotate_first: true };
    const ORI_ROT0_FLIPY: Orientation = Orientation { rotate: false, flip_y: true, flip_x: false, rotate_first: true };
    const ORI_ROT90_FLIPY: Orientation = Orientation { rotate: true, flip_y: true, flip_x: false, rotate_first: true };
    // ORI_FLIPY_ROT90 is the same as ORI_ROT90_FLIPX
    //const ORI_FLIPY_ROT90: Orientation = Orientation { rotate: true, flip_y: true, flip_x: false, rotate_first: false };
    const ORI_ROT0_FLIPX: Orientation = Orientation { rotate: false, flip_y: false, flip_x: true, rotate_first: true };
    const ORI_ROT90_FLIPX: Orientation = Orientation { rotate: true, flip_y: false, flip_x: true, rotate_first: true };
    // ORI_FLIPX_ROT90 is the same as ORI_ROT90_FLIPY
    //const ORI_FLIPX_ROT90: Orientation = Orientation { rotate: true, flip_y: false, flip_x: true, rotate_first: false };
    const ORI_ROT0_FLIPXY: Orientation = Orientation { rotate: false, flip_y: true, flip_x: true, rotate_first: true };
    const ORI_ROT90_FLIPXY: Orientation = Orientation { rotate: true, flip_y: true, flip_x: true, rotate_first: true };
    // ORI_FLIPXY_ROT90 is the same as ORI_ROT90_FLIPXY
    //const ORI_FLIPXY_ROT90: Orientation = Orientation { rotate: true, flip_y: true, flip_x: true, rotate_first: false };

    /// Return borders from all possible orienations of this tile.
    pub fn borders(&self) -> Vec<Border> {
        let naturals = self.naturals();
        let orientations: Vec<Orientation> = vec![
            Tile::ORI_ROT0, Tile::ORI_ROT90,
            Tile::ORI_ROT0_FLIPY, Tile::ORI_ROT90_FLIPY, Tile::ORI_ROT0_FLIPX,
            Tile::ORI_ROT90_FLIPX, Tile::ORI_ROT0_FLIPXY, Tile::ORI_ROT90_FLIPXY,
        ];
        for orientation in orientations {
            let borders = self.borders_of(orientation, &naturals);
            let patterns_s: Vec<String> = borders
                .iter()
                .map(|border| Border::pattern_string(border.pattern, self.width))
                .collect();
            eprintln!("{:?}", patterns_s);
        }
        vec![]
    }

    fn borders_of(&self, orientation: Orientation, naturals: &Vec<u32>) -> Vec<Border> {
        let mut patterns: Vec<u32> = naturals.iter().copied().collect();
        if orientation.rotate_first && orientation.rotate {
            patterns = vec![
                Tile::invert(patterns[3], self.width),
                patterns[0],
                Tile::invert(patterns[1], self.width),
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
                flip_patterns[1] = Tile::invert(patterns[1], self.height);
                flip_patterns[2] = patterns[0];
                flip_patterns[3] = Tile::invert(patterns[3], self.height);
            },
            (false, true) => {
                flip_patterns[0] = Tile::invert(patterns[0], self.width);
                flip_patterns[1] = patterns[3];
                flip_patterns[2] = Tile::invert(patterns[2], self.width);
                flip_patterns[3] = patterns[1];
            },
            (true, true) => {
                flip_patterns[0] = Tile::invert(patterns[2], self.width);
                flip_patterns[1] = Tile::invert(patterns[3], self.height);
                flip_patterns[2] = Tile::invert(patterns[0], self.width);
                flip_patterns[3] = Tile::invert(patterns[1], self.height);
            },
        }
        if !orientation.rotate_first && orientation.rotate {
            flip_patterns = vec![
                Tile::invert(flip_patterns[3], self.width),
                flip_patterns[0],
                Tile::invert(flip_patterns[1], self.width),
                flip_patterns[2],
            ];
        }
        let top = Border { tile_id: self.id, orientation, kind: BorderKind::Top, pattern: flip_patterns[0] };
        let right = Border { tile_id: self.id, orientation, kind: BorderKind::Right, pattern: flip_patterns[1] };
        let bottom = Border { tile_id: self.id, orientation, kind: BorderKind::Bottom, pattern: flip_patterns[2] };
        let left = Border { tile_id: self.id, orientation, kind: BorderKind::Left, pattern: flip_patterns[3] };
        vec![top, right, bottom, left]
    }

    pub fn naturals(&self) -> Vec<u32> {
        let mut naturals: Vec<u32> = vec![];
        let mut pattern: u32;
        // top
        pattern = 0;
        for i in 0..self.width {
            if self.pixel_at(0, i) { pattern |= Tile::bit_at_pos(i, self.width) }
        }
        naturals.push(pattern);
        // right
        pattern = 0;
        for i in 0..self.height {
            if self.pixel_at(i, self.width - 1) { pattern |= Tile::bit_at_pos(i, self.height) }
        }
        naturals.push(pattern);
        // bottom
        pattern = 0;
        for i in 0..self.width {
            if self.pixel_at(self.height - 1, i) { pattern |= Tile::bit_at_pos(i, self.width) }
        }
        naturals.push(pattern);
        // left
        pattern = 0;
        for i in 0..self.height {
            if self.pixel_at(i, 0) { pattern |= Tile::bit_at_pos(i, self.height) }
        }
        naturals.push(pattern);
        naturals
    }

    fn bit_at_pos(i: usize, edge: usize) -> u32 {
        let pos: u32 = u32::try_from(edge - 1 - i).unwrap();
        u32::try_from(2_i32.pow(pos)).unwrap()
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
}

#[cfg(test)]
mod tests {
    use super::*;

    const TINY_TILE: &'static str = "Tile 113:\n..#\n#..\n.##\n";

    #[test]
    fn test_parse_tile() {
        let tile: Tile = TINY_TILE.parse().unwrap();
        assert_eq!(113, tile.id);
        assert_eq!(3, tile.height);
        assert_eq!(3, tile.width);
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
        if let Err(e) = Tile::read_from_file("input/bad1.txt") {
            //assert_eq!(TileError::GridNotFound, *e);
            assert!(true);  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_read_from_file_invalid_line() {
        if let Err(e) = Tile::read_from_file("input/bad2.txt") {
            //assert_eq!(TileError::InvalidLine { line: "Spile 12:" }, *e);
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
        if let Err(e) = Pixel::from_char('?') {
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
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90() {
        let expect = vec!["####....#.", "...#.#.#.#", "......#..#", "#.##...##."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot0_flipy() {
        let expect = vec!["#.##...##.", "......#..#", "...#.#.#.#", "####....#."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0_FLIPY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipy() {
        let expect = vec!["......#..#", "#.#.#.#...", "####....#.", ".##...##.#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90_FLIPY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
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
//            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
//            .collect();
//        assert_eq!(expect, actual);
//    }

    #[test]
    fn test_tile_borders_rot0_flipx() {
        let expect = vec!["#.#.#.#...", ".#....####", ".##...##.#", "#..#......"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0_FLIPX, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipx() {
        let expect = vec![".#....####", "#.##...##.", "#..#......", "...#.#.#.#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90_FLIPX, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
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
//            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
//            .collect();
//        assert_eq!(expect, actual);
//    }

    #[test]
    fn test_tile_borders_rot0_flipxy() {
        let expect = vec![".##...##.#", "####....#.", "#.#.#.#...", "......#..#"];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT0_FLIPXY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
            .collect();
        assert_eq!(expect, actual);
    }

    #[test]
    fn test_tile_borders_rot90_flipxy() {
        let expect = vec!["#..#......", ".##...##.#", ".#....####", "#.#.#.#..."];
        let tile = &Tile::read_from_file("input/example1.txt").unwrap()[7];
        let actual: Vec<String> = tile.borders_of(Tile::ORI_ROT90_FLIPXY, &tile.naturals())
            .iter()
            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
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
//            .map(|border| Border::pattern_string(border.pattern, FIXED_WIDTH))
//            .collect();
//        assert_eq!(expect, actual);
//    }
}
