use custom_error::custom_error;
use crate::{Pixel, Tile};
use std::collections::HashMap;
use std::fmt;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub ImageError
    TilesNotFound = "aligned tiles not found",
    TilesNotSquare = "aligned tiles do not form a square",
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
}
