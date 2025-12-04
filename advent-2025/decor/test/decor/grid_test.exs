defmodule Decor.GridTest do
  use ExUnit.Case
  doctest Decor.Grid, import: true

  alias Decor.Grid

  describe "examples" do
    setup do
      [
        squares_1: [
          {{0, 0}, ?X},
          {{0, 1}, ?M},
          {{0, 2}, ?A},
          {{0, 3}, ?S},
          {{1, 0}, ?.},
          {{1, 1}, ?X},
          {{1, 2}, ?M},
          {{1, 3}, ?.},
          {{2, 0}, ?A},
          {{2, 1}, ?S},
          {{2, 2}, ?X},
          {{2, 3}, ?M},
        ],
        exp_grid_1: %Grid{
          size: %{y: 3, x: 4},
          squares: %{
            {0, 0} => ?X,
            {0, 1} => ?M,
            {0, 2} => ?A,
            {0, 3} => ?S,
            {1, 0} => ?.,
            {1, 1} => ?X,
            {1, 2} => ?M,
            {1, 3} => ?.,
            {2, 0} => ?A,
            {2, 1} => ?S,
            {2, 2} => ?X,
            {2, 3} => ?M,
          },
          meta: %{},
        },
        exp_double_grid_1: %Grid{
          size: %{y: 7, x: 9},
          squares: %{
            {1, 1} => ?X,
            {1, 3} => ?M,
            {1, 5} => ?A,
            {1, 7} => ?S,
            {3, 1} => ?.,
            {3, 3} => ?X,
            {3, 5} => ?M,
            {3, 7} => ?.,
            {5, 1} => ?A,
            {5, 3} => ?S,
            {5, 5} => ?X,
            {5, 7} => ?M,
          },
          meta: %{},
        },
        empty_y: 5,
        empty_x: 9,
        exp_empty_grid: %Grid{
          size: %{y: 5, x: 9},
          squares: %{},
          meta: %{},
        },
      ]
    end

    test "produce correct grids", fixture do
      act_grid = Grid.from_squares(fixture.squares_1)
      assert act_grid == fixture.exp_grid_1
    end

    test "produce correct double grid", fixture do
      act_double_grid =
        Grid.from_squares(fixture.squares_1)
        |> Grid.expand()
      assert act_double_grid == fixture.exp_double_grid_1
    end

    test "create empty grid", fixture do
      act_grid = Grid.create(fixture.empty_y, fixture.empty_x)
      assert act_grid == fixture.exp_empty_grid
    end

    test "set meta" do
      grid = Grid.create(3, 3)
             |> Grid.set_meta(:start, {0, 1})
      assert grid.meta.start == {0, 1}
    end

    test "find in-bounds cardinal neighbors", fixture do
      grid = fixture.exp_grid_1
      act_cardinals = Grid.cardinals_of(grid, {0, 0})
      exp_cardinals = [
        {0, 1},
        {1, 0},
      ]
      assert act_cardinals == exp_cardinals
      act_cardinals = Grid.cardinals_of(grid, {2, 3})
      exp_cardinals = [
        {1, 3},
        {2, 2},
      ]
      assert act_cardinals == exp_cardinals
    end

    test "find all cardinal neighbors", fixture do
      grid = fixture.exp_grid_1
      act_cardinals = Grid.cardinals_of(grid, {0, 0}, oob: true)
      exp_cardinals = [
        {-1, 0},
        {0, 1},
        {1, 0},
        {0, -1},
      ]
      assert act_cardinals == exp_cardinals
      act_cardinals = Grid.cardinals_of(grid, {2, 3}, oob: true)
      exp_cardinals = [
        {1, 3},
        {2, 4},
        {3, 3},
        {2, 2},
      ]
      assert act_cardinals == exp_cardinals
    end
  end
end
