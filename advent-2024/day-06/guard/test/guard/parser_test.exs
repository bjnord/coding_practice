defmodule Guard.ParserTest do
  use ExUnit.Case
  doctest Guard.Parser, import: true

  alias Xmas.Grid
  import Guard.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        ....#.....
        .........#
        ..........
        ..#.......
        .......#..
        ..........
        .#..^.....
        ........#.
        #.........
        ......#...
        """,
        exp_grid: %Grid{
          size: %{y: 10, x: 10},
          squares: %{
            {0, 4} => ?#, {1, 9} => ?#, {3, 2} => ?#, {4, 7} => ?#,
            {6, 1} => ?#, {7, 8} => ?#, {8, 0} => ?#, {9, 6} => ?#,
            {6, 4} => ?^,
          },
        },
      ]
    end

    test "produces correct grid", fixture do
      act_grid = fixture.input
                 |> parse_input_string()
      assert act_grid == fixture.exp_grid
    end
  end
end
