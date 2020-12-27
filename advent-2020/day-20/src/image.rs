use custom_error::custom_error;
use crate::{Pixel, Tile};
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
    pub fn pixel_at(&self, y: usize, x: usize) -> bool {
        self.pixels[self.pixels_index(y, x)].0
    }

    fn pixels_index(&self, y: usize, x: usize) -> usize {
        y * self.edge + x
    }

    /// Find sea monsters in image.
    pub fn find_sea_monsters(&self) {
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
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_image_from_tiles() {
        let tiles = Tile::read_from_file("input/example1.txt").unwrap();
        let image = Image::from_tiles(&tiles).unwrap();
        assert_eq!(24, image.edge);
        assert_eq!(24 * 24, image.pixels.len());
    }

    #[test]
    fn test_parse_image_pattern() {
        let pattern: ImagePattern = "__O_\n_OOO\nO___\n".parse().unwrap();
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
}
