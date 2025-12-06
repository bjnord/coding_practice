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
        exp_equations1: [
          {[123, 45, 6], :*},
          {[328, 64, 98], :+},
          {[51, 387, 215], :*},
          {[64, 23, 314], :+},
        ],
        exp_equations2: [
          {[4, 431, 623], :+},
          {[175, 581, 32], :*},
          {[8, 248, 369], :+},
          {[356, 24, 1], :*},
        ],
      ]
    end

    test "parser gets expected equations (part 1)", fixture do
      act_equations1 = fixture.input
                       |> parse_input_string(part: 1)
      assert act_equations1 == fixture.exp_equations1
    end

    test "parser gets expected equations (part 2)", fixture do
      act_equations2 = fixture.input
                       |> parse_input_string(part: 2)
      assert act_equations2 == fixture.exp_equations2
    end
  end
end
