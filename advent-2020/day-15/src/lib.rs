use std::collections::HashMap;

pub struct Game { }

impl Game {
    /// Return `n`th number spoken, given initial `numbers`.
    pub fn play(numbers: &[u32], n_turns: u32) -> u32 {
        let mut spoken_turn: HashMap::<u32, u32> = HashMap::new();
        for (t, &seed) in numbers.iter().enumerate() {
            spoken_turn.insert(seed, (t + 1) as u32);
        }
        let start_t: u32 = (numbers.len() + 1) as u32;
        let mut last_spoken: u32 = *numbers.last().unwrap();
        let mut last_spoken_turn: Option<u32> = None;
        for turn in start_t..=n_turns {
            last_spoken = match last_spoken_turn {
                Some(t) => {
                    let age = (turn - 1) - t;
                    age
                },
                None => {
                    0
                },
            };
            last_spoken_turn = match spoken_turn.get(&last_spoken) {
                Some(tr) => Some(*tr),
                None => None,
            };
            spoken_turn.insert(last_spoken, turn);
        }
        last_spoken
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_play_part_1_example_1() {
        assert_eq!(436, Game::play(&vec![0, 3, 6], 2020));
    }

    #[test]
    fn test_play_part_1_example_2() {
        assert_eq!(1, Game::play(&vec![1, 3, 2], 2020));
    }

    #[test]
    fn test_play_part_1_example_3() {
        assert_eq!(10, Game::play(&vec![2, 1, 3], 2020));
    }

    #[test]
    fn test_play_part_1_example_4() {
        assert_eq!(27, Game::play(&vec![1, 2, 3], 2020));
    }

    #[test]
    fn test_play_part_1_example_5() {
        assert_eq!(78, Game::play(&vec![2, 3, 1], 2020));
    }

    #[test]
    fn test_play_part_1_example_6() {
        assert_eq!(438, Game::play(&vec![3, 2, 1], 2020));
    }

    #[test]
    fn test_play_part_1_example_7() {
        assert_eq!(1836, Game::play(&vec![3, 1, 2], 2020));
    }
}
