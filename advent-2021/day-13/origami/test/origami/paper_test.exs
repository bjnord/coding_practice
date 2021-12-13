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
        exp_folded_1: %Origami.Paper{
          dimx: 11,
          dimy: 7,
          points: [
            {0, 0},
            {0, 1},
            {0, 3},
            {1, 4},
            {2, 0},
            {3, 0},
            {3, 4},
            {4, 1},
            {4, 3},
            {6, 0},
            {6, 2},
            {6, 4},
            {8, 4},
            {9, 0},
            {9, 4},
            {10, 2},
            {10, 4},
          ],
        },
        exp_folded_1_n_points: 17,
        exp_folded_2_render: """
        #####
        #...#
        #...#
        #...#
        #####
        .....
        .....
        """,
      ]
    end

    test "parser produces expected paper and instructions", fixture do
      {act_paper, act_instructions} =
        fixture.input
        |> Origami.Paper.parse_input_string()
      assert act_paper == fixture.exp_paper
      assert act_instructions == fixture.exp_instructions
    end

    test "folder produces correct first folded paper", fixture do
      act_folded_1 =
        fixture.exp_paper
        |> Origami.Paper.fold(List.first(fixture.exp_instructions))
      assert act_folded_1 == fixture.exp_folded_1
      assert Origami.Paper.n_points(act_folded_1) == fixture.exp_folded_1_n_points
    end

    test "folder produces correct final folded paper", fixture do
      act_folded_2_render =
        fixture.exp_paper
        |> Origami.Paper.fold(fixture.exp_instructions)
        |> Origami.Paper.render()
      assert act_folded_2_render == fixture.exp_folded_2_render
    end
  end
end
