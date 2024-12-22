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
          140,
          772,
          1930,
        ],
      ]
    end

    test "finds correct areas and perimeters", fixture do
      act_areas_perims =
        fixture.inputs
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(fn grid ->
          Fence.areas_perimeters(grid)
          |> Enum.sort()
        end)
      assert act_areas_perims == fixture.exp_areas_perims
    end

    test "finds correct prices", fixture do
      act_prices =
        fixture.inputs
        |> Enum.map(&parse_input_string/1)
        |> Enum.map(&Fence.prices/1)
      assert act_prices == fixture.exp_prices
    end
  end
end
