defmodule Dice.ParserTest do
  use ExUnit.Case
  doctest Dice.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        Player 1 starting position: 4
        Player 2 starting position: 8
        """,
        exp_start_positions: {4, 8},
      ]
    end

    test "parser gets expected starting positions", fixture do
      assert Dice.Parser.parse(fixture.input) == fixture.exp_start_positions
    end
  end
end
