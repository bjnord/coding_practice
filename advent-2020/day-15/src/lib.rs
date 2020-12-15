pub struct Game { }

impl Game {
    /// Return `n`th number spoken, given initial `numbers`.
    //
    // Vec<u32> is significantly faster than Vec<usize>, so we live with
    // the ugly "as" casts
    #[allow(clippy::cast_possible_truncation)]
    #[must_use]
    pub fn play(numbers: &[u32], n_turns: usize) -> u32 {
        // spoken numbers always < number of turns, so this works:
        let mut spoken_turn: Vec<u32> = vec![0; n_turns];
        for (t, &seed) in numbers.iter().enumerate() {
            spoken_turn[seed as usize] = (t + 1) as u32;
        }
        let start_t: usize = numbers.len() + 1;
        let mut last_spoken: u32 = *numbers.last().unwrap();
        let mut last_spoken_turn: usize = 0;
        for turn in start_t..=n_turns {
            last_spoken = if last_spoken_turn == 0 { 0 } else {
                ((turn - 1) - last_spoken_turn) as u32  // "age"
            };
            last_spoken_turn = spoken_turn[last_spoken as usize] as usize;
            spoken_turn[last_spoken as usize] = turn as u32;
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
