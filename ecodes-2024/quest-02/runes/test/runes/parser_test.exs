defmodule Runes.ParserTest do
  use ExUnit.Case
  doctest Runes.Parser, import: true

  import Runes.Parser

  describe "input parser" do
    setup do
      [
        input: """
        WORDS:THE,OWE,MES,ROD,HER

        AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE
        THE FLAME SHIELDED THE HEART OF THE KINGS
        """,
        exp_words: [~c"HER", ~c"MES", ~c"OWE", ~c"ROD", ~c"THE"],
        exp_inscriptions: [
          ~c"AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE",
          ~c"THE FLAME SHIELDED THE HEART OF THE KINGS",
        ],
        input2: """
        WORDS:MAX,MA,AN,AD,AND,MAD

        PER ARDUA AD ASTRA
        """,
        exp_words2: [~c"AND", ~c"MAD", ~c"MAX", ~c"AD", ~c"AN", ~c"MA"],
      ]
    end

    test "gets expected words and inscription", fixture do
      {act_words, act_inscriptions} =
        fixture.input
        |> parse_input_string()
      assert act_words == fixture.exp_words
      assert act_inscriptions == fixture.exp_inscriptions
    end

    test "sorts words longest first, then alpha", fixture do
      {act_words2, _} =
        fixture.input2
        |> parse_input_string()
      assert act_words2 == fixture.exp_words2
    end
  end
end
