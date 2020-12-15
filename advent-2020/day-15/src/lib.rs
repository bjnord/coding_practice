pub struct Game { }

impl Game {
    /// Return `n`th number spoken, given initial `numbers`.
    pub fn play(numbers: &[u32], n_turns: u32) -> u32 {
        // spoken numbers always < number of turns, so this works:
        let mut spoken_turn: Vec<u32> = vec![0; n_turns as usize];
        for (t, &seed) in numbers.iter().enumerate() {
            spoken_turn[seed as usize] = (t + 1) as u32;
        }
        let start_t: u32 = (numbers.len() + 1) as u32;
        let mut last_spoken: u32 = *numbers.last().unwrap();
        let mut last_spoken_turn: u32 = 0;
        for turn in start_t..=n_turns {
            last_spoken = if last_spoken_turn == 0 { 0 } else {
                (turn - 1) - last_spoken_turn  // "age"
            };
            last_spoken_turn = spoken_turn[last_spoken as usize];
            spoken_turn[last_spoken as usize] = turn;
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
