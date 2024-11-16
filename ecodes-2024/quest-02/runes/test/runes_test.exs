defmodule RunesTest do
  use ExUnit.Case
  doctest Runes

  describe "part 1 examples" do
    setup do
      [
        part1_words: ["THE","OWE","MES","ROD","HER"],
        part1_inscription1: "AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE",
        part1_exp_match1a: nil,
        part1_exp_match1b: "THE",
        part1_exp_match1c: "OWE",
        part1_exp_count1: 4,
        part1_inscription2: "THE FLAME SHIELDED THE HEART OF THE KINGS",
        part1_exp_count2: 3,
        part1_inscription3: "POWE PO WER P OWE R",
        part1_exp_count3: 2,
        part1_inscription4: "THERE IS THE END",
        part1_exp_count4: 3,
      ]
    end

    test "part 1 rune word match example 1a", fixture do
      chars1 = fixture.part1_inscription1
               |> to_charlist()
      act_match1a = fixture.part1_words
                    |> Runes.begin_match?(chars1)
      assert act_match1a == fixture.part1_exp_match1a
    end

    test "part 1 rune word match example 1b", fixture do
      chars1 = fixture.part1_inscription1
               |> to_charlist()
               |> Enum.slice(7, 999)
      act_match1b = fixture.part1_words
                    |> Runes.begin_match?(chars1)
      assert act_match1b == fixture.part1_exp_match1b
    end

    test "part 1 rune word match example 1c", fixture do
      chars1 = fixture.part1_inscription1
               |> to_charlist()
               |> Enum.slice(12, 999)
      act_match1c = fixture.part1_words
                    |> Runes.begin_match?(chars1)
      assert act_match1c == fixture.part1_exp_match1c
    end

    # TODO RF use array for the 4 examples

    test "part 1 rune word count example 1", fixture do
      act_count1 = fixture.part1_words
                   |> Runes.match_count(fixture.part1_inscription1)
      assert act_count1 == fixture.part1_exp_count1
    end

    test "part 1 rune word count example 2", fixture do
      act_count2 = fixture.part1_words
                   |> Runes.match_count(fixture.part1_inscription2)
      assert act_count2 == fixture.part1_exp_count2
    end

    test "part 1 rune word count example 3", fixture do
      act_count3 = fixture.part1_words
                   |> Runes.match_count(fixture.part1_inscription3)
      assert act_count3 == fixture.part1_exp_count3
    end

    test "part 1 rune word count example 4", fixture do
      act_count4 = fixture.part1_words
                   |> Runes.match_count(fixture.part1_inscription4)
      assert act_count4 == fixture.part1_exp_count4
    end
  end
end
