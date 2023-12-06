defmodule Race.ParserTest do
  use ExUnit.Case
  doctest Race.Parser, import: true

  import Race.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        Time:      7  15   30
        Distance:  9  40  200
        """,
        exp_races: [
          {7, 9},
          {15, 40},
          {30, 200},
        ],
      ]
    end

    test "parser gets expected races", fixture do
      act_races = fixture.input
                  |> parse_input_string()
      assert act_races == fixture.exp_races
    end
  end
end
