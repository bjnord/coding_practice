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
  end
end
