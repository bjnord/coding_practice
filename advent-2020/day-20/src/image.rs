use custom_error::custom_error;
use crate::{Orientation, Pixel, Tile};
use std::collections::HashMap;
use std::fmt;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub ImageError
    TilesNotFound = "aligned tiles not found",
    TilesNotSquare = "aligned tiles do not form a square",
    GridNotFound = "image pattern grid not found",
    InvalidPixel{pixel: char} = "invalid pixel character '{pixel}'",
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Image {
    pixels: Vec<Pixel>,
    edge: usize,
}

impl fmt::Display for Image {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
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

impl Image {
    /// Construct from matrix of oriented tiles.
    ///
    /// # Errors
    ///
    /// Returns `Err` if [...].
    pub fn from_tiles(tiles: &Vec<Tile>) -> Result<Image> {
        let matrix = Tile::aligned_borders(tiles);
        if matrix.is_empty() {
            return Err(ImageError::TilesNotFound.into())
        }
        if matrix[0].is_empty() {
            return Err(ImageError::TilesNotFound.into())
        }
        if matrix.len() != matrix[0].len() {
            return Err(ImageError::TilesNotSquare.into())
        }
        let medge = matrix[0].len();
        let edge = (matrix[0][0].edge - 2) * medge;
        let tedge = tiles[0].edge;
        let tile_index = Image::tile_index(tiles);
        let mut pixels: Vec<Pixel> = vec![];
        for (_my, row) in matrix.into_iter().enumerate() {
            let mut pixrows: Vec<Vec<Pixel>> = vec![vec![]; tedge-2];
            for (_mx, bord) in row.into_iter().enumerate() {
                let tile = tile_index[&bord.tile_id];
                //eprintln!("M{}({}, {}) tedge={} tile_id={} bord = {}", mi, my, mx, tedge, tile.id, bord);
                for y in 1..tedge-1 {
                    for x in 1..tedge-1 {
                        //eprintln!("copy T{} pix({}, {}, {}) as I({}, {})", mi, bord.orientation, y, x, (tedge-2) * my + (y-1), (tedge-2) * mx + (x-1));
                        let pixel = Pixel(tile.pixel_at(bord.orientation, y, x));
                        pixrows[y-1].push(pixel)
                    }
                }
            }
            pixels.extend::<Vec<Pixel>>(pixrows.iter().flatten().copied().collect());
        }
        Ok(Image { pixels, edge })
    }

    fn tile_index(tiles: &Vec<Tile>) -> HashMap<u32, &Tile> {
        let mut index: HashMap<u32, &Tile> = HashMap::new();
        for tile in tiles {
            index.insert(tile.id, tile);
        }
        index
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

    const MONSTER: &'static str = "\
        __________________O_\n\
        O____OO____OO____OOO\n\
        _O__O__O__O__O__O___\n";
    const MONSTER_PIXELS: usize = 15;

    /// Find sea monsters in image.
    pub fn sea_roughness(&self) -> usize {
        let pattern: ImagePattern = Image::MONSTER.parse().unwrap();
        for orientation in Tile::all_orientations() {
            let count = pattern.find_in(&self, orientation).len();
            if count > 0 {
                let waves: usize = self.pixels
                    .iter()
                    .filter(|&pix| *pix == Pixel(true))
                    .count();
                return waves - count * Image::MONSTER_PIXELS;
            }
        }
        0
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct PixelPattern(bool);

impl PixelPattern {
    /// Construct pixel from input character.
    #[must_use]
    pub fn from_char(pixel: char) -> Result<PixelPattern> {
        match pixel {
            '_' => Ok(PixelPattern(false)),
            'O' => Ok(PixelPattern(true)),
            _ => Err(ImageError::InvalidPixel { pixel }.into())
        }
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct ImagePattern {
    height: usize,
    width: usize,
    pixels: Vec<PixelPattern>,
}

impl fmt::Display for ImagePattern {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for y in 0..self.height {
            for x in 0..self.width {
                s += match self.pixel_at(y, x) {
                    false => "_",
                    true => "O",
                };
            }
            s += "\n";
        }
        write!(f, "{}", s)
    }
}

impl FromStr for ImagePattern {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let width = input
            .lines()
            .next()
            .ok_or_else(|| ImageError::GridNotFound)?
            .trim()
            .len();
        let pixels: Vec<PixelPattern> = input
            .lines()
            .flat_map(|line| line.trim().chars().map(PixelPattern::from_char))
            .collect::<Result<Vec<PixelPattern>>>()?;
        let height = pixels.len() / width;
        Ok(Self { height, width, pixels })
    }
}

impl ImagePattern {
    /// Return pixel at (y, x).
    #[must_use]
    pub fn pixel_at(&self, y: usize, x: usize) -> bool {
        self.pixels[self.pixels_index(y, x)].0
    }

    fn pixels_index(&self, y: usize, x: usize) -> usize {
        y * self.width + x
    }

    /// Find pattern in the given `image` when in the given `orientation`.
    /// Returns a list of (y, x) coordinates where the pattern was found.
    pub fn find_in(&self, image: &Image, orientation: Orientation) -> Vec<(usize, usize)> {
        let mut positions: Vec<(usize, usize)> = vec![];
        for y in 0..image.edge {
            for x in 0..image.edge {
                if self.find_at(image, orientation, y, x) {
                    positions.push((y, x));
                }
            }
        }
        positions
    }

    fn find_at(&self, image: &Image, orientation: Orientation, y: usize, x: usize) -> bool {
        for py in 0..self.height {
            for px in 0..self.width {
                let y1 = y + py;
                let x1 = x + px;
                if y1 >= image.edge || x1 >= image.edge {
                    return false;
                }
                if self.pixel_at(py, px) && !image.pixel_at(orientation, y1, x1) {
                    return false;
                }
            }
        }
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const MONSTER_HEAD: &'static str = "\
        __O_\n\
        _OOO\n\
        O___\n";
    const SMALL_POND: &'static str = "Tile 1\n\
        ##..##.#..\n
        #.#.#.#.##\n
        .##..#.#.#\n
        .##.##..#.\n
        ...#.##.#.\n
        .##.#.##.#\n
        .##.#.##.#\n
        #.#..##.#.\n
        .#.#..#.##\n
        .#.##...#.\n";
    const CORNER_POND: &'static str = "Tile 1\n\
        ..........\n\
        ...#...#..\n\
        ..###.###.\n\
        .#...#....\n\
        ..........\n\
        ..........\n\
        ...#...#..\n\
        ..###.###.\n\
        .#...#....\n\
        ..........\n";
    const OUTSIDE_POND: &'static str = "Tile 1\n\
        ...#......\n\
        ..###...#.\n\
        .#.....###\n\
        ......#...\n\
        ..........\n\
        ..........\n\
        ..#.......\n\
        .###...#..\n\
        #.....###.\n\
        .....#....\n";

    #[test]
    fn test_image_from_tiles() {
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        let image = Image::from_tiles(&tiles).unwrap();
        assert_eq!(24, image.edge);
        assert_eq!(24 * 24, image.pixels.len());
    }

    #[test]
    fn test_parse_image_pattern() {
        let pattern: ImagePattern = MONSTER_HEAD.parse().unwrap();
        assert_eq!(4, pattern.width);
        assert_eq!(3, pattern.height);
        assert_eq!(false, pattern.pixel_at(0, 0));
        assert_eq!(false, pattern.pixel_at(2, 3));
        assert_eq!(true, pattern.pixel_at(0, 2));
        assert_eq!(true, pattern.pixel_at(1, 3));
        assert_eq!(true, pattern.pixel_at(2, 0));
    }

    #[test]
    fn test_parse_image_pattern_none() {
        match "".parse::<ImagePattern>() {
            Err(e) => assert!(e.to_string().contains("image pattern grid not found")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_parse_image_pattern_invalid_pixel() {
        match "O_O\n_X_\n__O\n".parse::<ImagePattern>() {
            Err(e) => assert!(e.to_string().contains("invalid pixel character 'X'")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_find_in_small_pond() {
        let pattern: ImagePattern = MONSTER_HEAD.parse().unwrap();
        let tile: Tile = SMALL_POND.parse().unwrap();
        assert_eq!(10, tile.edge);
        let tiles = vec![tile];
        let image = Image::from_tiles(&tiles).unwrap();
        assert_eq!(8, image.edge);
        let positions = pattern.find_in(&image, Tile::ORI_ROT0);
        assert_eq!(0, positions.len());
        let positions = pattern.find_in(&image, Tile::ORI_ROT90_FLIPX);
        assert_eq!(3, positions.len());
    }

    #[test]
    fn test_find_in_corner_pond() {
        let pattern: ImagePattern = MONSTER_HEAD.parse().unwrap();
        let tile: Tile = CORNER_POND.parse().unwrap();
        assert_eq!(10, tile.edge);
        let tiles = vec![tile];
        let image = Image::from_tiles(&tiles).unwrap();
        let positions = pattern.find_in(&image, Tile::ORI_ROT0);
        assert_eq!(4, positions.len());
    }

    #[test]
    fn test_find_in_outside_pond() {
        let pattern: ImagePattern = MONSTER_HEAD.parse().unwrap();
        let tile: Tile = OUTSIDE_POND.parse().unwrap();
        assert_eq!(10, tile.edge);
        let tiles = vec![tile];
        let image = Image::from_tiles(&tiles).unwrap();
        let positions = pattern.find_in(&image, Tile::ORI_ROT0);
        assert_eq!(0, positions.len());
    }

    #[test]
    fn test_find_in() {
        let pattern: ImagePattern = Image::MONSTER.parse().unwrap();
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        let image = Image::from_tiles(&tiles).unwrap();
        let positions = pattern.find_in(&image, Tile::ORI_ROT0);
//        // FOR DEBUGGING: if first corner is locked (so input/example1.txt
//        // comes out as the puzzle description has it), uncomment these:
//        assert_eq!(0, positions.len());
//        let positions = pattern.find_in(&image, Tile::ORI_ROT90_FLIPX);
        assert_eq!(2, positions.len());
    }

    #[test]
    fn test_sea_roughness() {
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        let image = Image::from_tiles(&tiles).unwrap();
        assert_eq!(273, image.sea_roughness());
    }
}
