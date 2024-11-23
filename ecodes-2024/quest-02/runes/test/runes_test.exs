defmodule RunesTest do
  use ExUnit.Case
  doctest Runes

  describe "part 1 examples" do
    setup do
      [
        part1_words: [~c"HER", ~c"MES", ~c"OWE", ~c"ROD", ~c"THE"],
        part1_inscription1: ~c"AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE",
        part1_exp_match1a: nil,
        part1_exp_match1b: ~c"THE",
        part1_exp_match1c: ~c"OWE",
        part1_exp_count1: 4,
        part1_inscription2: ~c"THE FLAME SHIELDED THE HEART OF THE KINGS",
        part1_exp_count2: 3,
        part1_inscription3: ~c"POWE PO WER P OWE R",
        part1_exp_count3: 2,
        part1_inscription4: ~c"THERE IS THE END",
        part1_exp_count4: 3,
        part2_words: [~c"HER", ~c"MES", ~c"OWE", ~c"QAQ", ~c"ROD", ~c"THE"],
        part2_inscriptions: [
          ~c"AWAKEN THE POWE ADORNED WITH THE FLAMES BRIGHT IRE",
          ~c"THE FLAME SHIELDED THE HEART OF THE KINGS",
          ~c"POWE PO WER P OWE R",
          ~c"THERE IS THE END",
          ~c"QAQAQ",
        ],
        part2_exp_counts: [15, 9, 6, 7, 5],
        part3_words: [~c"MES", ~c"OWE", ~c"ROD", ~c"RODEO", ~c"THE"],
        part3_inscriptions: [
          ~c"HELWORLT",
          ~c"ENIGWDXL",
          ~c"TRODEOAL",
        ],
        part3_exp_cols: [
          ~c"HET",
          ~c"ENR",
          ~c"LIO",
          ~c"WGD",
          ~c"OWE",
          ~c"RDO",
          ~c"LXA",
          ~c"TLL",
        ],
      ]
    end

    test "part 1 rune word match example 1a", fixture do
      irunes1 = fixture.part1_inscription1
      act_match1a = fixture.part1_words
                    |> Runes.find_word(irunes1)
      assert act_match1a == fixture.part1_exp_match1a
    end

    test "part 1 rune word match example 1b", fixture do
      irunes1 = fixture.part1_inscription1
                |> Enum.slice(7, 999)
      act_match1b = fixture.part1_words
                    |> Runes.find_word(irunes1)
      assert act_match1b == fixture.part1_exp_match1b
    end

    test "part 1 rune word match example 1c", fixture do
      irunes1 = fixture.part1_inscription1
                |> Enum.slice(12, 999)
      act_match1c = fixture.part1_words
                    |> Runes.find_word(irunes1)
      assert act_match1c == fixture.part1_exp_match1c
    end

    # TODO RF use array for the 4 examples

    test "part 1 rune word count example 1", fixture do
      act_count1 = fixture.part1_words
                   |> Runes.word_count(fixture.part1_inscription1)
      assert act_count1 == fixture.part1_exp_count1
    end

    test "part 1 rune word count example 2", fixture do
      act_count2 = fixture.part1_words
                   |> Runes.word_count(fixture.part1_inscription2)
      assert act_count2 == fixture.part1_exp_count2
    end

    test "part 1 rune word count example 3", fixture do
      act_count3 = fixture.part1_words
                   |> Runes.word_count(fixture.part1_inscription3)
      assert act_count3 == fixture.part1_exp_count3
    end

    test "part 1 rune word count example 4", fixture do
      act_count4 = fixture.part1_words
                   |> Runes.word_count(fixture.part1_inscription4)
      assert act_count4 == fixture.part1_exp_count4
    end

    test "part 2", fixture do
      act_counts =
        fixture.part2_inscriptions
        |> Enum.map(fn inscription ->
          fixture.part2_words
          |> Runes.rune_count(inscription)
        end)
      assert act_counts == fixture.part2_exp_counts
    end

    test "part 3 cols", fixture do
      act_cols =
        fixture.part3_inscriptions
        |> Runes.inscription_cols()
      assert act_cols == fixture.part3_exp_cols
    end
  end
end
