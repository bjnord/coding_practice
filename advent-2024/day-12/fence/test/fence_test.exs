defmodule FenceTest do
  use ExUnit.Case
  doctest Fence

  import Fence.Parser

  describe "puzzle example" do
    setup do
      [
        inputs: [
          """
          AAAA
          BBCD
          BBCC
          EEEC
          """,
          """
          OOOOO
          OXOXO
          OOOOO
          OXOXO
          OOOOO
          """,
          """
          RRRRIICCFF
          RRRRIICCCF
          VVRRRCCFFF
          VVRCCCJFFF
          VVVVCJJCFE
          VVIVCCJJEE
          VVIIICJJEE
          MIIIIIJJEE
          MIIISIJEEE
          MMMISSJEEE
          """,
          """
          EEEEE
          EXXXX
          EEEEE
          EXXXX
          EEEEE
          """,
          """
          AAAAAA
          AAABBA
          AAABBA
          ABBAAA
          ABBAAA
          AAAAAA
          """,
        ],
        exp_areas_perims: [
          [
            {?A, {4, 10}},
            {?B, {4, 8}},
            {?C, {4, 10}},
            {?D, {1, 4}},
            {?E, {3, 8}},
          ],
          [
            {?O, {21, 36}},
            {?X, {1, 4}},
            {?X, {1, 4}},
            {?X, {1, 4}},
            {?X, {1, 4}},
          ],
          [
            {?C, {1, 4}},
            {?C, {14, 28}},
            {?E, {13, 18}},
            {?F, {10, 18}},
            {?I, {4, 8}},
            {?I, {14, 22}},
            {?J, {11, 20}},
            {?M, {5, 12}},
            {?R, {12, 18}},
            {?S, {3, 8}},
            {?V, {13, 20}},
          ],
        ],
        exp_prices: [
          140,   # [0]
          772,   # [1]
          1930,  # [2]
        ],
        exp_areas_sides: [
          {?A, {4, [
            {{0, 1}, ?-}, {{2, 1}, ?-}, {{1, 0}, ?|},
            {{0, 3}, ?-}, {{2, 3}, ?-},
            {{0, 5}, ?-}, {{2, 5}, ?-},
            {{0, 7}, ?-}, {{1, 8}, ?|}, {{2, 7}, ?-},
          ]}},
          {?B, {4, [
            {{2, 1}, ?-}, {{3, 0}, 124},
            {{2, 3}, 45}, {{3, 4}, 124},
            {{6, 1}, 45}, {{5, 0}, 124},
            {{5, 4}, ?|}, {{6, 3}, 45},
          ]}},
          {?C, {4, [
            {{2, 5}, ?-}, {{3, 6}, ?|}, {{3, 4}, ?|},
            {{6, 5}, ?-}, {{5, 4}, ?|},
            {{4, 7}, ?-}, {{5, 8}, ?|},
            {{7, 8}, ?|}, {{8, 7}, ?-}, {{7, 6}, ?|},
          ]}},
          {?D, {1, [
            {{2, 7}, 45}, {{3, 8}, 124}, {{4, 7}, 45}, {{3, 6}, 124},
          ]}},
          {?E, {3, [
            {{6, 1}, 45}, {{8, 1}, 45}, {{7, 0}, 124},
            {{6, 3}, 45}, {{8, 3}, 45},
            {{6, 5}, 45}, {{7, 6}, 124}, {{8, 5}, 45},
          ]}},
        ],
        exp_bulk_prices: [
          80,    # [0]
          436,   # [1]
          1206,  # [2]
          236,   # [3]
          368,   # [4]
        ],
      ]
    end

    test "finds correct areas and perimeters", fixture do
      act_areas_perims =
        fixture.inputs
        |> Enum.slice(0..2)  # just Part One examples
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(fn grid ->
          Fence.areas_perimeters(grid)
          |> Enum.sort()
        end)
      assert act_areas_perims == fixture.exp_areas_perims
    end

    test "finds correct area and sides", fixture do
      act_areas_sides =
        hd(fixture.inputs)
        |> parse_input_string()
        |> Fence.areas_sides()
        |> Enum.sort()
      assert act_areas_sides == fixture.exp_areas_sides
    end

    test "finds correct prices", fixture do
      act_prices =
        fixture.inputs
        |> Enum.slice(0..2)  # just Part One examples
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(&Fence.prices/1)
      assert act_prices == fixture.exp_prices
    end

    # FIXME temporary comment-out
    #test "finds correct bulk prices", fixture do
    #  act_bulk_prices =
    #    fixture.inputs
    #    |> Enum.map(&parse_input_string/1)
    #    |> Enum.map(&Fence.bulk_prices/1)
    #  assert act_bulk_prices == fixture.exp_bulk_prices
    #end
  end
end
