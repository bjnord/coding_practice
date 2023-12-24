defmodule Hail.ParserTest do
  use ExUnit.Case
  doctest Hail.Parser, import: true

  import Hail.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        19, 13, 30 @ -2,  1, -2
        18, 19, 22 @ -1, -1, -2
        20, 25, 34 @ -2, -2, -4
        12, 31, 28 @ -1, -2, -1
        20, 19, 15 @  1, -5, -3
        """,
        exp_entries: [
          {{19, 13, 30}, {-2,  1, -2}},
          {{18, 19, 22}, {-1, -1, -2}},
          {{20, 25, 34}, {-2, -2, -4}},
          {{12, 31, 28}, {-1, -2, -1}},
          {{20, 19, 15}, { 1, -5, -3}},
        ],
      ]
    end

    test "parser gets expected entries", fixture do
      act_entries = fixture.input
                    |> parse_input_string()
                    |> Enum.to_list()
      assert act_entries == fixture.exp_entries
    end
  end
end
