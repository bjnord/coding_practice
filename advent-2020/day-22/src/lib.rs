#[macro_use] extern crate scan_fmt;

use custom_error::custom_error;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub DeckError
    InvalidLine{line: String} = "invalid card line [{line}]",
    NoCards = "deck has no cards",
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub struct Card(u32);

impl fmt::Display for Card {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}\n", self.0)
    }
}

#[derive(Debug)]
pub struct Deck {
    player: u32,
    cards: Vec<Card>,
}

impl FromStr for Deck {
    type Err = Box<dyn std::error::Error>;

    fn from_str(input: &str) -> Result<Self> {
        let mut i = input.lines();
        let label = i.next().unwrap();
        let (who, player) = scan_fmt!(label, "{s} {d}", String, u32)?;
        if who != "Player" {
            return Err(DeckError::InvalidLine { line: label.to_string() }.into());
        }
        let card_nos: Vec<u32> = input
            .lines()
            .skip(1)
            .map(|v| v.parse::<u32>().map_err(|e| e.into()))
            .collect::<Result<Vec<u32>>>()?;
        if card_nos.is_empty() {
            return Err(DeckError::NoCards.into());
        }
        let cards: Vec<Card> = card_nos
            .iter()
            .map(|&n| Card(n))
            .collect();
        Ok(Self { player, cards })
    }
}

impl fmt::Display for Deck {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        let label = format!("Player {}:\n", self.player);
        s += &label;
        for card in self.cards.iter() {
            s += &format!("{}\n", card);
        }
        write!(f, "{}", s)
    }
}

impl Deck {
    /// Construct by reading deck from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<Vec<Deck>> {
        let s: String = fs::read_to_string(path)?;
        s.split("\n\n").map(str::parse).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file_1() {
        let decks = Deck::read_from_file("input/example1.txt").unwrap();
        assert_eq!(2, decks.len());
        assert_eq!(1, decks[0].player);
        assert_eq!(vec![Card(9), Card(2), Card(6), Card(3), Card(1)], decks[0].cards);
        assert_eq!(2, decks[1].player);
        assert_eq!(5, decks[1].cards.len());
    }

    #[test]
    fn test_read_from_file_no_file() {
        match Deck::read_from_file("input/example99.txt") {
            Err(e) => assert!(e.to_string().contains("No such file")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_invalid_line() {
        if let Err(e) = Deck::read_from_file("input/bad1.txt") {
            //assert_eq!(DeckError::InvalidLine { line: "Slayer 2:" }, *e);
            assert!(e.to_string().contains("invalid card line"));  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_read_from_file_no_cards() {
        if let Err(e) = Deck::read_from_file("input/bad2.txt") {
            //assert_eq!(DeckError::NoCards, *e);
            assert!(e.to_string().contains("deck has no cards"));  // FIXME
        } else {
            panic!("test did not fail");
        }
    }

    #[test]
    fn test_read_from_file_invalid_card() {
        match Deck::read_from_file("input/bad3.txt") {
            Err(e) => assert!(e.to_string().contains("invalid digit")),
            Ok(_)  => panic!("test did not fail"),
        }
    }
}
