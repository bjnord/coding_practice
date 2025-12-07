defmodule SplitTest do
  use ExUnit.Case
  doctest Split

  alias Decor.Grid

  describe "puzzle example" do
    setup do
      [
        grid: %Grid{
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
        exp_split_count: 21,
        inputs: [
          """
          ...S...
          .......
          ...^...
          .......
          ..^.^..
          .......
          """,
          """
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
        ],
        exp_world_counts: [
          4,
          40,
        ],
      ]
    end

    test "produces correct split count", fixture do
      act_split_count =
        fixture.grid
        |> Split.count_splits()
      assert act_split_count == fixture.exp_split_count
    end

    test "produces correct world counts", fixture do
      act_world_counts =
        fixture.inputs
        |> Enum.map(&Split.Parser.parse_input_string/1)
        |> Enum.map(&Split.count_worlds/1)
      assert act_world_counts == fixture.exp_world_counts
    end
  end
end
