defmodule Runes.ParserTest do
  use ExUnit.Case
  doctest Runes.Parser, import: true

  import Runes.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        WORDS:THE,OWE,MES,ROD,HER

        AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE
        """,
        exp_words: ["THE","OWE","MES","ROD","HER"],
        exp_inscriptions: ["AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE"],
      ]
    end

    test "parser gets expected words and inscription", fixture do
      {act_words, act_inscriptions} =
        fixture.input
        |> parse_input_string()
      assert act_words == fixture.exp_words
      assert act_inscriptions == fixture.exp_inscriptions
    end
  end
end
