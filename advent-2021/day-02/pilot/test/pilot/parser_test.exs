defmodule Pilot.ParserTest do
  use ExUnit.Case
  doctest Pilot.Parser

  alias Pilot.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        forward 5
        down 5
        forward 8
        up 3
        down 8
        forward 2
        """,
        exp_steps: [
          {5, 0},
          {0, 5},
          {8, 0},
          {0, -3},
          {0, 8},
          {2, 0},
        ],
      ]
    end

    test "parser gets expected steps", fixture do
      act_steps =
        fixture.input
        |> String.split("\n", trim: true)
        |> Parser.parse_lines()
      assert act_steps == fixture.exp_steps
    end
  end
end
