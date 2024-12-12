defmodule FenceTest do
  use ExUnit.Case
  doctest Fence

  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        grids: [
          %Grid{
            size: %{y: 4, x: 4},
            squares: %{
              {0, 0} => ?A, {0, 1} => ?A, {0, 2} => ?A, {0, 3} => ?A,
              {1, 0} => ?B, {1, 1} => ?B, {1, 2} => ?C, {1, 3} => ?D,
              {2, 0} => ?B, {2, 1} => ?B, {2, 2} => ?C, {2, 3} => ?C,
              {3, 0} => ?E, {3, 1} => ?E, {3, 2} => ?E, {3, 3} => ?C,
            },
          },
          %Grid{
            size: %{y: 5, x: 5},
            squares: %{
              {0, 0} => ?O, {0, 1} => ?O, {0, 2} => ?O, {0, 3} => ?O, {0, 4} => ?O,
              {1, 0} => ?O, {1, 1} => ?X, {1, 2} => ?O, {1, 3} => ?X, {1, 4} => ?O,
              {2, 0} => ?O, {2, 1} => ?O, {2, 2} => ?O, {2, 3} => ?O, {2, 4} => ?O,
              {3, 0} => ?O, {3, 1} => ?X, {3, 2} => ?O, {3, 3} => ?X, {3, 4} => ?O,
              {4, 0} => ?O, {4, 1} => ?O, {4, 2} => ?O, {4, 3} => ?O, {4, 4} => ?O,
            },
          },
        ],
        exp_areas_perims: [
          %{
            ?A => {4, 10},
            ?B => {4, 8},
            ?C => {4, 10},
            ?D => {1, 4},
            ?E => {3, 8},
          },
          %{
            ?O => {21, 36},
            ?X => {4, 16},
          },
        ],
        exp_prices: [
          140,
          772,
        ],
      ]
    end

    test "finds correct areas and perimeters", fixture do
      act_areas_perims = fixture.grids
                         |> Enum.map(&Fence.areas_perimeters/1)
      assert act_areas_perims == fixture.exp_areas_perims
    end

    test "finds correct prices", fixture do
      act_prices = fixture.grids
                   |> Enum.map(&Fence.prices/1)
      assert act_prices == fixture.exp_prices
    end
  end
end
