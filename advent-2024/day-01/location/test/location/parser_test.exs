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
        exp_entries: [
          {3, 4},
          {4, 3},
          {2, 5},
          {1, 3},
          {3, 9},
          {3, 3},
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
