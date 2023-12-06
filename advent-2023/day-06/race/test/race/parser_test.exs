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
        exp_races_part1: [
          {7, 9},
          {15, 40},
          {30, 200},
        ],
        exp_races_part2: [
          {71530, 940200},
        ]
      ]
    end

    test "parser gets expected races (part 1)", fixture do
      act_races = fixture.input
                  |> parse_input_string(part: 1)
      assert act_races == fixture.exp_races_part1
    end

    test "parser gets expected races (part 2)", fixture do
      act_races = fixture.input
                  |> parse_input_string(part: 2)
      assert act_races == fixture.exp_races_part2
    end
  end
end
