defmodule Hydrothermal.ParserTest do
  use ExUnit.Case
  doctest Hydrothermal.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        0,9 -> 5,9
        8,0 -> 0,8
        9,4 -> 3,4
        2,2 -> 2,1
        7,0 -> 7,4
        6,4 -> 2,0
        0,9 -> 2,9
        3,4 -> 1,4
        0,0 -> 8,8
        5,5 -> 8,2
        """,
        exp_vents: [
          [{0, 9}, {5, 9}],
          [{8, 0}, {0, 8}],
          [{9, 4}, {3, 4}],
          [{2, 2}, {2, 1}],
          [{7, 0}, {7, 4}],
          [{6, 4}, {2, 0}],
          [{0, 9}, {2, 9}],
          [{3, 4}, {1, 4}],
          [{0, 0}, {8, 8}],
          [{5, 5}, {8, 2}],
        ],
      ]
    end

    test "parser gets expected vents", fixture do
      act_vents = fixture.input
                  |> Hydrothermal.Parser.parse_input_string(fixture.input)
                  |> Enum.map(fn v -> v end)
      assert act_vents == fixture.exp_vents
    end
  end
end
