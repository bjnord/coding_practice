defmodule Smoke.ParserTest do
  use ExUnit.Case
  doctest Smoke.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        2199943210
        3987894921
        9856789892
        8767896789
        9899965678
        """,
        exp_locations: [
          [2, 1, 9, 9, 9, 4, 3, 2, 1, 0], 
          [3, 9, 8, 7, 8, 9, 4, 9, 2, 1], 
          [9, 8, 5, 6, 7, 8, 9, 8, 9, 2], 
          [8, 7, 6, 7, 8, 9, 6, 7, 8, 9], 
          [9, 8, 9, 9, 9, 6, 5, 6, 7, 8], 
        ],
      ]
    end

    test "parser gets expected locations", fixture do
      act_locations = fixture.input
                    |> Smoke.Parser.parse_input_string()
                    |> Enum.map(fn e -> e end)
      assert act_locations == fixture.exp_locations
    end
  end
end
