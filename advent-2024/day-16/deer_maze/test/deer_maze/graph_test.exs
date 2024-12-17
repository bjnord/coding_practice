defmodule DeerMaze.GraphTest do
  use ExUnit.Case
  doctest DeerMaze.Graph, import: true

  alias DeerMaze.Graph
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
        exp_graphs: [
          %Graph{
            nodes: %{
              {1, 3} => [{{3, 3}, 1002, :middle}],
              {3, 1} => [{{1, 3}, 2004, :middle}, {{3, 3}, 1002, :middle}],
              {3, 3} => [{{5, 9}, 3008, :middle}],
              {5, 9} => [{{1, 13}, 5012, :end}],
              {7, 3} => [{{7, 5}, 1002, :middle}, {{3, 1}, 2006, :middle}],
              {7, 5} => [{{7, 9}, 1004, :middle}, {{9, 5}, 1002, :middle}],
              {7, 9} => [{{5, 9}, 1002, :middle}, {{1, 13}, 4022, :end}],
              {9, 3} => [{{7, 3}, 1002, :middle}, {{11, 3}, 1002, :middle}],
              {9, 5} => [{{11, 9}, 2006, :middle}],
              {11, 1} => [{{9, 3}, 2004, :middle}, {{11, 3}, 1002, :middle}],
              {11, 3} => [{{11, 5}, 1002, :middle}],
              {11, 5} => [{{9, 5}, 1002, :middle}, {{13, 7}, 2004, :middle}],
              {13, 1} => [{{11, 1}, 1002, :middle}],
              {13, 7} => [{{11, 9}, 2004, :middle}, {{11, 9}, 2004, :middle}]
            },
            meta: %{
              start: {13, 1},
              end: {1, 13},
            },
          },
          %Graph{
            nodes: %{
              {1, 15} => [{{7, 15}, 1006, :middle}],
              {3, 7} => [{{3, 11}, 4008, :middle}],
              {3, 11} => [{{3, 13}, 1002, :middle}, {{5, 11}, 1002, :middle}],
              {3, 13} => [{{1, 15}, 2004, :end}],
              {5, 1} => [{{5, 3}, 3010, :middle}, {{5, 3}, 1002, :middle}],
              {5, 3} => [{{7, 3}, 1002, :middle}],
              {5, 11} => [{{9, 9}, 2006, :middle}],
              {7, 3} => [{{3, 7}, 4012, :middle}, {{15, 5}, 2010, :middle}],
              {9, 7} => [{{9, 9}, 1002, :middle}],
              {9, 9} => [{{7, 15}, 3008, :middle}],
              {11, 11} => [{{7, 15}, 4008, :middle}],
              {13, 5} => [{{9, 7}, 3006, :middle}, {{13, 11}, 1006, :middle}],
              {13, 11} => [{{11, 11}, 1002, :middle}],
              {15, 1} => [{{5, 1}, 1010, :middle}],
              {15, 5} => [{{13, 5}, 1002, :middle}]
            },
            meta: %{
              start: {15, 1},
              end: {1, 15},
            },
          },
          %Graph{
            nodes: %{
              {{1, 3}, :north} => [{{1, 5}, :end, 1002}, {{3, 3}, :south, 1002}],
              {{1, 3}, :west} => [{{1, 5}, :end, 1002}, {{3, 3}, :south, 1002}],
              {{1, 5}, :end} => [{{3, 5}, :south, 1002}, {{1, 3}, :west, 1002}],
              {{3, 3}, :east} => [{{1, 3}, :north, 1002}, {{3, 5}, :east, 2}],
              {{3, 3}, :north} => [{{1, 3}, :north, 2}, {{3, 5}, :east, 1002}],
              {{3, 5}, :east} => [{{1, 5}, :end, 1002}, {{3, 3}, :west, 1002}],
              {{3, 5}, :south} => [{{1, 5}, :end, 1002}, {{3, 3}, :west, 1002}],
              {{5, 1}, :east} => [{{3, 3}, :east, 2004}, {{3, 3}, :north, 1004}]
            },
            meta: %{
              start: {5, 1},
              end: {1, 5},
            },
          },
        ],
      ]
    end

    test "produces correct graphs", fixture do
      act_graphs = fixture.inputs
                   |> Enum.slice(2..2)  # FIXME DEBUG TEMP
                   |> Enum.map(&parse_input_string/1)
                   |> Enum.map(&Graph.from_grid/1)
      assert act_graphs == fixture.exp_graphs
                           |> Enum.slice(2..2)  # FIXME DEBUG TEMP
    end
  end
end