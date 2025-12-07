defmodule Split.ParserTest do
  use ExUnit.Case
  doctest Split.Parser, import: true

  import Split.Parser
  alias Decor.Grid

  describe "puzzle example" do
    setup do
      [
        input: """
        .......S.......
        ...............
        .......^.......
        ...............
        ......^.^......
        ...............
        .....^.^.^.....
        ...............
        ....^.^...^....
        ...............
        ...^.^...^.^...
        ...............
        ..^...^.....^..
        ...............
        .^.^.^.^.^...^.
        ...............
        """,
        exp_grid: %Grid{
          # (NB empty row/column is trimmed off the end)
          size: %{y: 15, x: 14},
          squares: %{
                {2, 7} => ?^,
                {4, 6} => ?^,
                {4, 8} => ?^,
                {6, 5} => ?^,
                {6, 7} => ?^,
                {6, 9} => ?^,
                {8, 4} => ?^,
                {8, 6} => ?^,
                {8, 10} => ?^,
                {10, 3} => ?^,
                {10, 5} => ?^,
                {10, 9} => ?^,
                {10, 11} => ?^,
                {12, 2} => ?^,
                {12, 6} => ?^,
                {12, 12} => ?^,
                {14, 1} => ?^,
                {14, 3} => ?^,
                {14, 5} => ?^,
                {14, 7} => ?^,
                {14, 9} => ?^,
                {14, 13} => ?^,
          },
          meta: %{start: {0, 7}},
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
