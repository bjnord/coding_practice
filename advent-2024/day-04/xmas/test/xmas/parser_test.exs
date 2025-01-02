defmodule Xmas.ParserTest do
  use ExUnit.Case
  doctest Xmas.Parser, import: true

  alias History.Grid
  import Xmas.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        MMMSXXMASM
        MSAMXMSMSA
        AMXSXMAAMM
        MSAMASMSMX
        XMASAMXAMM
        XXAMMXXAMA
        SMSMSASXSS
        SAXAMASAAA
        MAMMMXMMMM
        MXMXAXMASX
        """,
        exp_grid: %Grid{
          size: %{y: 10, x: 10},
          squares: %{
            {0, 0} => ?M, {0, 1} => ?M, {0, 2} => ?M, {0, 3} => ?S, {0, 4} => ?X,
            {0, 5} => ?X, {0, 6} => ?M, {0, 7} => ?A, {0, 8} => ?S, {0, 9} => ?M,
            {1, 0} => ?M, {1, 1} => ?S, {1, 2} => ?A, {1, 3} => ?M, {1, 4} => ?X,
            {1, 5} => ?M, {1, 6} => ?S, {1, 7} => ?M, {1, 8} => ?S, {1, 9} => ?A,
            {2, 0} => ?A, {2, 1} => ?M, {2, 2} => ?X, {2, 3} => ?S, {2, 4} => ?X,
            {2, 5} => ?M, {2, 6} => ?A, {2, 7} => ?A, {2, 8} => ?M, {2, 9} => ?M,
            {3, 0} => ?M, {3, 1} => ?S, {3, 2} => ?A, {3, 3} => ?M, {3, 4} => ?A,
            {3, 5} => ?S, {3, 6} => ?M, {3, 7} => ?S, {3, 8} => ?M, {3, 9} => ?X,
            {4, 0} => ?X, {4, 1} => ?M, {4, 2} => ?A, {4, 3} => ?S, {4, 4} => ?A,
            {4, 5} => ?M, {4, 6} => ?X, {4, 7} => ?A, {4, 8} => ?M, {4, 9} => ?M,
            {5, 0} => ?X, {5, 1} => ?X, {5, 2} => ?A, {5, 3} => ?M, {5, 4} => ?M,
            {5, 5} => ?X, {5, 6} => ?X, {5, 7} => ?A, {5, 8} => ?M, {5, 9} => ?A,
            {6, 0} => ?S, {6, 1} => ?M, {6, 2} => ?S, {6, 3} => ?M, {6, 4} => ?S,
            {6, 5} => ?A, {6, 6} => ?S, {6, 7} => ?X, {6, 8} => ?S, {6, 9} => ?S,
            {7, 0} => ?S, {7, 1} => ?A, {7, 2} => ?X, {7, 3} => ?A, {7, 4} => ?M,
            {7, 5} => ?A, {7, 6} => ?S, {7, 7} => ?A, {7, 8} => ?A, {7, 9} => ?A,
            {8, 0} => ?M, {8, 1} => ?A, {8, 2} => ?M, {8, 3} => ?M, {8, 4} => ?M,
            {8, 5} => ?X, {8, 6} => ?M, {8, 7} => ?M, {8, 8} => ?M, {8, 9} => ?M,
            {9, 0} => ?M, {9, 1} => ?X, {9, 2} => ?M, {9, 3} => ?X, {9, 4} => ?A,
            {9, 5} => ?X, {9, 6} => ?M, {9, 7} => ?A, {9, 8} => ?S, {9, 9} => ?X,
          }
        },
      ]
    end

    test "produces correct grid", fixture do
      act_grid =
        fixture.input
        |> parse_input_string()

      assert act_grid == fixture.exp_grid
    end
  end
end
