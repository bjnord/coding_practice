defmodule Trash.ParserTest do
  use ExUnit.Case
  doctest Trash.Parser, import: true

  import Trash.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        123 328  51 64 
         45 64  387 23 
          6 98  215 314
        *   +   *   +
        """,
        exp_equations: [
          {[123, 45, 6], :*},
          {[328, 64, 98], :+},
          {[51, 387, 215], :*},
          {[64, 23, 314], :+},
        ],
      ]
    end

    test "parser gets expected equations", fixture do
      act_equations = fixture.input
                      |> parse_input_string()
      assert act_equations == fixture.exp_equations
    end
  end
end
