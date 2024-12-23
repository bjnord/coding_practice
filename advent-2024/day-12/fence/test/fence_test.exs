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
        exp_fence_squares: [
          {?A, [
            {{0, 1}, ?-}, {{2, 1}, ?=}, {{1, 0}, ?|},
            {{0, 3}, ?-}, {{2, 3}, ?=},
            {{0, 5}, ?-}, {{2, 5}, ?=},
            {{0, 7}, ?-}, {{1, 8}, ?I}, {{2, 7}, ?=},
          ]},
          {?B, [
            {{2, 1}, ?-}, {{3, 0}, ?|},
            {{2, 3}, ?-}, {{3, 4}, ?I},
            {{6, 1}, ?=}, {{5, 0}, ?|},
            {{5, 4}, ?I}, {{6, 3}, ?=},
          ]},
          {?C, [
            {{2, 5}, ?-}, {{3, 6}, ?I}, {{3, 4}, ?|},
            {{6, 5}, ?=}, {{5, 4}, ?|},
            {{4, 7}, ?-}, {{5, 8}, ?I},
            {{7, 8}, ?I}, {{8, 7}, ?=}, {{7, 6}, ?|},
          ]},
          {?D, [
            {{2, 7}, ?-}, {{3, 8}, ?I}, {{4, 7}, ?=}, {{3, 6}, ?|},
          ]},
          {?E, [
            {{6, 1}, ?-}, {{8, 1}, ?=}, {{7, 0}, ?|},
            {{6, 3}, ?-}, {{8, 3}, ?=},
            {{6, 5}, ?-}, {{7, 6}, ?I}, {{8, 5}, ?=},
          ]},
        ],
        exp_sides: [
          [
            {?A, {4, 4}},
            {?B, {4, 4}},
            {?C, {4, 8}},
            {?D, {1, 4}},
            {?E, {3, 4}},
          ],
          [
            {?O, {21, 20}},
            {?X, {1, 4}},
            {?X, {1, 4}},
            {?X, {1, 4}},
            {?X, {1, 4}},
          ],
          [
            {?E, {13, 8}},
            {?S, {3, 6}},
            {?F, {10, 12}},
            {?C, {14, 22}},
            {?J, {11, 12}},
            {?I, {4, 4}},
            {?V, {13, 10}},
            {?R, {12, 10}},
            {?C, {1, 4}},
            {?I, {14, 16}},
            {?M, {5, 6}},
          ],
          [
            {?E, {17, 12}},
            {?X, {4, 4}},
            {?X, {4, 4}},
          ],
          [
            {?B, {4, 4}},
            {?A, {28, 12}},
            {?B, {4, 4}},
          ],
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

    test "finds correct fence squares", fixture do
      act_fence_squares =
        hd(fixture.inputs)
        |> parse_input_string()
        |> Fence.fence_squares()
        |> Enum.sort()
      assert act_fence_squares == fixture.exp_fence_squares
    end

    test "finds correct sides", fixture do
      act_sides =
        fixture.inputs
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(&Fence.areas_sides/1)
      assert act_sides == fixture.exp_sides
    end

    test "finds correct prices", fixture do
      act_prices =
        fixture.inputs
        |> Enum.slice(0..2)  # just Part One examples
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(&Fence.prices/1)
      assert act_prices == fixture.exp_prices
    end

    test "finds correct bulk prices", fixture do
      act_bulk_prices =
        fixture.inputs
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(&Fence.bulk_prices/1)
      assert act_bulk_prices == fixture.exp_bulk_prices
    end
  end
end
