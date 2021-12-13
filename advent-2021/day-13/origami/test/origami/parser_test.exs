defmodule Origami.ParserTest do
  use ExUnit.Case
  doctest Origami.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        6,10
        0,14
        9,10
        0,3
        10,4
        4,11
        6,0
        6,12
        4,1
        0,13
        10,12
        3,4
        3,0
        8,4
        1,10
        2,14
        8,10
        9,0

        fold along y=7
        fold along x=5
        """,
        exp_points: [
          {6, 10},
          {0, 14},
          {9, 10},
          {0, 3},
          {10, 4},
          {4, 11},
          {6, 0},
          {6, 12},
          {4, 1},
          {0, 13},
          {10, 12},
          {3, 4},
          {3, 0},
          {8, 4},
          {1, 10},
          {2, 14},
          {8, 10},
          {9, 0},
        ],
        exp_instructions: [
          {:fold_y, 7},
          {:fold_x, 5},
        ],
      ]
    end

    test "parser gets expected points and instructions", fixture do
      {act_points, act_instructions} =
        fixture.input
        |> Origami.Parser.parse_input_string()
      assert act_points == fixture.exp_points
      assert act_instructions == fixture.exp_instructions
    end
  end
end
