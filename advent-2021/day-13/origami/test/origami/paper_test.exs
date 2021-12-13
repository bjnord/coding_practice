defmodule Origami.PaperTest do
  use ExUnit.Case
  doctest Origami.Paper

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
        exp_paper: %Origami.Paper{
          dimx: 11,
          dimy: 15,
          points: [
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
        },
        exp_instructions: [
          {:fold_y, 7},
          {:fold_x, 5},
        ],
      ]
    end

    test "parser gets expected paper and instructions", fixture do
      {act_paper, act_instructions} =
        fixture.input
        |> Origami.Paper.parse_input_string()
      assert act_paper == fixture.exp_paper
      assert act_instructions == fixture.exp_instructions
    end
  end
end
