defmodule DeerMazeTest do
  use ExUnit.Case
  doctest DeerMaze

  import DeerMaze.Parser

  describe "puzzle examples" do
    setup do
      [
        inputs: [
          """
          ###############
          #.......#....E#
          #.#.###.#.###.#
          #.....#.#...#.#
          #.###.#####.#.#
          #.#.#.......#.#
          #.#.#####.###.#
          #...........#.#
          ###.#.#####.#.#
          #...#.....#.#.#
          #.#.#.###.#.#.#
          #.....#...#.#.#
          #.###.#.#.#.#.#
          #S..#.....#...#
          ###############
          """,
          """
          #################
          #...#...#...#..E#
          #.#.#.#.#.#.#.#.#
          #.#.#.#...#...#.#
          #.#.#.#.###.#.#.#
          #...#.#.#.....#.#
          #.#.#.#.#.#####.#
          #.#...#.#.#.....#
          #.#.#####.#.###.#
          #.#.#.......#...#
          #.#.###.#####.###
          #.#.#...#.....#.#
          #.#.#.#####.###.#
          #.#.#.........#.#
          #.#.#.#########.#
          #S#.............#
          #################
          """,
          """
          #######
          #....E#
          ###.#.#
          #.....#
          #.#.#.#
          #S..#.#
          #######
          """,
        ],
        exp_scores: [
          7036,
          11048,
          2008,
        ],
      ]
    end

    test "produces correct scores", fixture do
      act_scores = fixture.inputs
                   |> Enum.slice(2..2)  # FIXME DEBUG TEMP
                   |> Enum.map(&parse_input_string/1)
                   |> Enum.map(&DeerMaze.score/1)
      assert act_scores == fixture.exp_scores
                           |> Enum.slice(2..2)  # FIXME DEBUG TEMP
    end
  end
end
