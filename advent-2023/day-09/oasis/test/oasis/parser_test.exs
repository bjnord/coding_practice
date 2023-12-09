defmodule Oasis.ParserTest do
  use ExUnit.Case
  doctest Oasis.Parser, import: true

  import Oasis.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        0 3 6 9 12 15
        1 3 6 10 15 21
        10 13 16 21 30 45
        """,
        exp_entries: [
          [0, 3, 6, 9, 12, 15],
          [1, 3, 6, 10, 15, 21],
          [10, 13, 16, 21, 30, 45],
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
