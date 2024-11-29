defmodule Runes.ArtifactTest do
  use ExUnit.Case
  doctest Runes.Parser, import: true

  import Runes.Artifact
  import Runes.Parser

  describe "word/rune finders" do
    setup do
      [
        p1_input: """
        WORDS:THE,OWE,MES,ROD,HER

        AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE
        """,
        exp_p1_word_count: 4,
        p2_input: """
        WORDS:THE,OWE,MES,ROD,HER,QAQ

        AWAKEN THE POWE ADORNED WITH THE FLAMES BRIGHT IRE
        THE FLAME SHIELDED THE HEART OF THE KINGS
        POWE PO WER P OWE R
        THERE IS THE END
        QAQAQ
        """,
        exp_p2_rune_matches: [
          [
            {0, 7}, {0, 8}, {0, 9},
            {0, 12}, {0, 13}, {0, 14},
            {0, 17}, {0, 18}, {0, 19},
            {0, 29}, {0, 30}, {0, 31},
            {0, 36}, {0, 37}, {0, 38},
          ],
          [
            {1, 0}, {1, 1}, {1, 2},
            {1, 19}, {1, 20}, {1, 21},
            {1, 32}, {1, 33}, {1, 34},
          ],
          [
            {2, 1}, {2, 2}, {2, 3},
            {2, 14}, {2, 15}, {2, 16},
          ],
          [
            {3, 0}, {3, 1}, {3, 2}, {3, 3},
            {3, 9}, {3, 10}, {3, 11},
          ],
          [
            {4, 0}, {4, 1}, {4, 2}, {4, 3}, {4, 4},
          ],
        ],
        p3_input: """
        WORDS:THE,OWE,MES,ROD,RODEO

        HELWORLT
        ENIGWDXL
        TRODEOAL
        """,
      ]
    end

    test "finds part 1 word count", fixture do
      act_count =
        fixture.p1_input
        |> parse_input_string()
        |> word_row_count(0)
      assert act_count == fixture.exp_p1_word_count
    end

    test "finds part 2 rune matches", fixture do
      artifact =
        fixture.p2_input
        |> parse_input_string()
      act_matches =
        0..(artifact.height - 1)
        |> Enum.map(&(rune_row_matches(artifact, &1)))
      assert act_matches == fixture.exp_p2_rune_matches
    end
  end
end
