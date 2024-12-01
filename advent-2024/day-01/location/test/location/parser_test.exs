defmodule Location.ParserTest do
  use ExUnit.Case
  doctest Location.Parser, import: true

  import Location.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        3   4
        4   3
        2   5
        1   3
        3   9
        3   3
        """,
        exp_location_lists: {
          [3, 4, 2, 1, 3, 3],
          [4, 3, 5, 3, 9, 3],
        },
      ]
    end

    test "parser gets expected location lists", fixture do
      act_location_lists = fixture.input
                           |> parse_input_string()
      assert act_location_lists == fixture.exp_location_lists
    end
  end
end
