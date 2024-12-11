defmodule Pluto.ParserTest do
  use ExUnit.Case
  doctest Pluto.Parser, import: true

  import Pluto.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        0 1 10 99 999
        """,
        exp_stones: [
          0, 1, 10, 99, 999,
        ],
      ]
    end

    test "parser gets expected stones", fixture do
      act_stones = fixture.input
                   |> parse_input_string()
      assert act_stones == fixture.exp_stones
    end
  end
end
