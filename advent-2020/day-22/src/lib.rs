#[macro_use] extern crate scan_fmt;
use std::collections::HashSet;

use custom_error::custom_error;
use std::cmp;
use std::convert::TryFrom;
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
        writeln!(f, "{}", self.0)
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
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
        for card in &self.cards {
            s += &format!("{}\n", card);
        }
        write!(f, "{}", s)
    }
}

impl Deck {
    /// Return formatted list of cards in the deck.
    #[must_use]
    pub fn as_string(&self) -> String {
        self.cards
            .iter()
            .map(|c| c.0.to_string())
            .collect::<Vec<String>>()
            .join(", ")
    }

    /// Is the deck empty?
    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.cards.is_empty()
    }

    /// Does the deck have at least `n` cards?
    #[must_use]
    pub fn has_at_least(&self, n: u32) -> bool {
        self.cards.len() >= usize::try_from(n).unwrap()
    }

    /// Return score of cards in the deck.
    #[must_use]
    pub fn score(&self) -> u32 {
        let n_cards = self.cards.len();
        self.cards
            .iter()
            .enumerate()
            .map(|(i, card)| u32::try_from(n_cards - i).unwrap() * card.0)
            .sum()
    }

    /// Return clone of the deck with copies of the first `n` cards.
    #[must_use]
    pub fn cloned_n(&self, n: u32) -> Deck {
        let nz = usize::try_from(n).unwrap();
        if self.cards.len() < nz {
            panic!("asked for {} cards, only have {}", nz, self.cards.len());
        }
        Deck { player: self.player, cards: self.cards.iter().take(nz).copied().collect() }
    }

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

pub struct Game {
    game: usize,
    decks: Vec<Deck>,
    output: bool,
    seen: HashSet<u64>,
    winner: usize,
    n_games: usize,
}

impl Game {
    /// Construct from game number and decks. If `output` is true, `play()`
    /// will produce output on stdout as the game progresses.
    #[must_use]
    pub fn from_decks(game: usize, decks: Vec<Deck>, output: bool) -> Game {
        let seen: HashSet<u64> = HashSet::new();
        Game { game, decks, seen, output, winner: 0, n_games: 0 }
    }

    /// Play the game. Returns the winning player number, and the recursive
    /// games played count, as a tuple.
    pub fn play(&mut self) -> (usize, usize) {
        if self.output && self.game > 0 {
            println!("=== Game {} ===", self.game);
            println!();
        }
        for round in 1..u32::MAX {
            if self.output {
                if self.game > 0 {
                    println!("-- Round {} (Game {}) --", round, self.game);
                } else {
                    println!("-- Round {} --", round);
                }
                println!("Player 1's deck: {}", self.decks[0].as_string());
                println!("Player 2's deck: {}", self.decks[1].as_string());
            }
            // "Before either player deals a card, if there was a previous
            // round in this game that had exactly the same cards in the
            // same order in the same players' decks, the game instantly
            // ends in a win for player 1. Previous rounds from other games
            // are not considered. (This prevents infinite games of
            // Recursive Combat, which everyone agrees is a bad idea.)"
            let game_hash = self.hash();
            if self.seen.contains(&game_hash) {
                self.winner = 1;
                break;
            } else {
                self.seen.insert(game_hash);
            }
            let p1: Vec<Card> = self.decks[0].cards.drain(..1).collect();
            let p2: Vec<Card> = self.decks[1].cards.drain(..1).collect();
            if self.output {
                println!("Player 1 plays: {}", p1[0].0);
                println!("Player 2 plays: {}", p2[0].0);
            }
            if self.game > 0 {
                self.decide_round_winner_recursively(round, p1[0], p2[0]);
            } else {
                self.decide_round_winner(round, p1[0], p2[0]);
            }
            if self.decks[1].is_empty() {
                self.winner = 1;
                break;
            }
            if self.decks[0].is_empty() {
                self.winner = 2;
                break;
            }
            if self.output {
                println!();
            }
        }
        if self.output && self.game < 2 {
            if self.game == 1 {
                println!("The winner of game 1 is player {}!", self.winner);
            }
            println!();
            println!();
            println!("== Post-game results ==");
            println!("Player 1's deck: {}", self.decks[0].as_string());
            println!("Player 2's deck: {}", self.decks[1].as_string());
        }
        (self.winner, cmp::max(self.n_games, self.game))
    }

    fn decide_round_winner(&mut self, round: u32, p1_card: Card, p2_card: Card) {
        let winner = if p1_card.0 > p2_card.0 { 1 } else { 2 };
        self.finish_round(round, winner, p1_card, p2_card);
    }

    fn finish_round(&mut self, round: u32, winner: usize, p1_card: Card, p2_card: Card) {
        if self.output {
            if self.game == 0 {
                println!("Player {} wins the round!", winner);
            } else {
                println!("Player {} wins round {} of game {}!", winner, round, self.game);
            }
        }
        if winner == 1 {
            self.decks[0].cards.push(p1_card);
            self.decks[0].cards.push(p2_card);
        } else {
            self.decks[1].cards.push(p2_card);
            self.decks[1].cards.push(p1_card);
        }
    }

    fn decide_round_winner_recursively(&mut self, round: u32, p1_card: Card, p2_card: Card) {
        if self.decks[0].has_at_least(p1_card.0) && self.decks[1].has_at_least(p2_card.0) {
            if self.output {
                println!("Playing a sub-game to determine the winner...");
                println!();
            }
            let new_decks = vec![
                self.decks[0].cloned_n(p1_card.0),
                self.decks[1].cloned_n(p2_card.0),
            ];
            if self.game > self.n_games {
                self.n_games = self.game;
            }
            let mut game = Game::from_decks(self.n_games + 1, new_decks, self.output);
            let (winner, new_n_games) = game.play();
            if self.output {
                println!("The winner of game {} is player {}!", self.n_games + 1, winner);
                println!();
                println!("...anyway, back to game {}.", self.game);
            }
            self.n_games = new_n_games;
            self.finish_round(round, winner, p1_card, p2_card);
        } else {
            self.decide_round_winner(round, p1_card, p2_card);
        }
    }

    /// Returns player number and deck score of the game winner, as a tuple.
    #[must_use]
    pub fn winner(&self) -> (usize, u32) {
        (self.winner, self.decks[self.winner - 1].score())
    }

    // Returns cards in the given `player`'s deck.
    #[cfg(test)]
    fn cards(&self, player: usize) -> &Vec<Card> {
        &self.decks[player - 1].cards
    }

    // Returns hash of the decks' state.
    fn hash(&self) -> u64 {
        let mut hash = 1_u64;
        hash = self.decks[0].cards
            .iter()
            .enumerate()
            .fold(hash, |acc, (i, card)| acc.wrapping_mul(u64::try_from(card.0).unwrap()).wrapping_add(u64::try_from(i).unwrap() + 1));
        hash = hash.wrapping_mul(1202).wrapping_add(81518);
        hash = self.decks[1].cards
            .iter()
            .enumerate()
            .fold(hash, |acc, (i, card)| acc.wrapping_mul(u64::try_from(card.0).unwrap()).wrapping_add(u64::try_from(i).unwrap() + 1));
        hash
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
        assert_eq!("5, 8, 4, 7, 10", decks[1].as_string());
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
        match Deck::read_from_file("input/bad1.txt") {
            Err(e) => assert_eq!("invalid card line [Slayer 2:]", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_no_cards() {
        match Deck::read_from_file("input/bad2.txt") {
            Err(e) => assert_eq!("deck has no cards", e.to_string()),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_read_from_file_invalid_card() {
        match Deck::read_from_file("input/bad3.txt") {
            Err(e) => assert!(e.to_string().contains("invalid digit")),
            Ok(_)  => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_deck_cloned_n() {
        let deck0 = Deck { player: 1, cards: vec![Card(1), Card(2), Card(3), Card(5), Card(8)] };
        let deck1 = Deck { player: 1, cards: vec![Card(1), Card(2), Card(3)] };
        assert_eq!(deck1, deck0.cloned_n(3));
        assert_eq!(deck0, deck0.cloned_n(5));
    }

    #[test]
    #[should_panic]
    fn test_deck_cloned_n_too_big() {
        let deck0 = Deck { player: 1, cards: vec![Card(1), Card(2), Card(3), Card(5), Card(8)] };
        assert_eq!(deck0, deck0.cloned_n(6));
    }

    #[test]
    fn test_game_hash() {
        let decks = vec![
            Deck { player: 1, cards: vec![Card(2), Card(3), Card(5)] },
            Deck { player: 2, cards: vec![Card(7), Card(11)] },
        ];
        let game = Game::from_decks(0, decks, false);
        // see also `bin/hash.sh`
        assert_eq!(11645031, game.hash());
    }

    #[test]
    fn test_play() {
        let decks = Deck::read_from_file("input/example1.txt").unwrap();
        let mut game = Game::from_decks(0, decks, true);
        let exp_winner = 2;
        assert_eq!((exp_winner, 0), game.play());
        assert_eq!((exp_winner, 306), game.winner());
        let exp_winner_cards: Vec<Card> = game.cards(exp_winner)
            .iter()
            .map(|&c| Card(c.0))
            .collect();
        assert_eq!(vec![Card(3), Card(2), Card(10), Card(6), Card(8),
            Card(5), Card(9), Card(4), Card(7), Card(1)], exp_winner_cards);
        assert!(game.cards(3 - exp_winner).is_empty());
    }

    #[test]
    fn test_play_recursive() {
        let decks = Deck::read_from_file("input/example1.txt").unwrap();
        let mut game = Game::from_decks(1, decks, true);
        let exp_winner = 2;
        assert_eq!((exp_winner, 5), game.play());
        assert_eq!((exp_winner, 291), game.winner());
        let exp_winner_cards: Vec<Card> = game.cards(exp_winner)
            .iter()
            .map(|&c| Card(c.0))
            .collect();
        assert_eq!(vec![Card(7), Card(5), Card(6), Card(2), Card(4),
            Card(1), Card(10), Card(8), Card(9), Card(3)], exp_winner_cards);
        assert!(game.cards(3 - exp_winner).is_empty());
    }

    #[test]
    fn test_play_recursive_loop() {
        let decks = Deck::read_from_file("input/example2.txt").unwrap();
        let mut game = Game::from_decks(1, decks, true);
        game.play();
        assert_eq!(1, game.winner().0);
    }
}
