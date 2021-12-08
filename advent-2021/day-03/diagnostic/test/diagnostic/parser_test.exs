defmodule Diagnostic.ParserTest do
  use ExUnit.Case
  doctest Diagnostic.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        00100
        11110
        10110
        10111
        10101
        01111
        00111
        11100
        10000
        11001
        00010
        01010
        """,
        exp_entries: [
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 1, 1, 0],
          [1, 0, 1, 1, 1],
          [1, 0, 1, 0, 1],
          [0, 1, 1, 1, 1],
          [0, 0, 1, 1, 1],
          [1, 1, 1, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 1, 0, 1, 0],
        ],
      ]
    end

    test "parser gets expected entries", fixture do
      act_entries = fixture.input
                    |> Diagnostic.Parser.parse_input_string()
                    |> Enum.map(fn e -> e end)
      assert act_entries == fixture.exp_entries
    end
  end
end
