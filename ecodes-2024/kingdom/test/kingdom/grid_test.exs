defmodule Kingdom.GridTest do
  use ExUnit.Case
  doctest Kingdom.Grid, import: true

  alias Kingdom.Grid

  describe "examples" do
    setup do
      [
        squares_1: [
          {{0, 0}, 0},
          {{0, 1}, 0},
          {{0, 2}, 1},
          {{0, 3}, 2},
          {{1, 0}, 3},
          {{1, 1}, 3},
          {{1, 2}, 1},
          {{1, 3}, 1},
          {{2, 0}, 4},
          {{2, 1}, 3},
          {{2, 2}, 0},
          {{2, 3}, 0},
        ],
        exp_grid_1: %Grid{
          size: %{y: 3, x: 4},
          squares: %{
            {0, 0} => 0,
            {0, 1} => 0,
            {0, 2} => 1,
            {0, 3} => 2,
            {1, 0} => 3,
            {1, 1} => 3,
            {1, 2} => 1,
            {1, 3} => 1,
            {2, 0} => 4,
            {2, 1} => 3,
            {2, 2} => 0,
            {2, 3} => 0,
          }
        },
        positions_1: [
          {0, 0},
          {0, 1},
          {1, 0},
          {1, 1},
          {1, 3},
          {2, 2},
          {2, 3},
        ],
        exp_neighbors_1: [
          [{0, 1}, {1, 0}, {1, 1}],
          [{0, 0}, {0, 2}, {1, 0}, {1, 1}, {1, 2}],
          [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}],
          [{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 2}, {2, 0}, {2, 1}, {2, 2}],
          [{0, 2}, {0, 3}, {1, 2}, {2, 2}, {2, 3}],
          [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 3}],
          [{1, 2}, {1, 3}, {2, 2}],
        ],
        exp_cardinals_1: [
          [{0, 1}, {1, 0}],
          [{0, 2}, {1, 1}, {0, 0}],
          [{0, 0}, {1, 1}, {2, 0}],
          [{0, 1}, {1, 2}, {2, 1}, {1, 0}],
          [{0, 3}, {2, 3}, {1, 2}],
          [{1, 2}, {2, 3}, {2, 1}],
          [{1, 3}, {2, 2}],
        ],
      ]
    end

    test "produce correct grids", fixture do
      act_grid = Grid.from_squares(fixture.squares_1)
      assert act_grid == fixture.exp_grid_1
    end

    test "produce correct neighbors", fixture do
      grid = Grid.from_squares(fixture.squares_1)
      act_neighbors =
        fixture.positions_1
        |> Enum.map(&(Grid.neighbors_of(grid, &1)))
      assert act_neighbors == fixture.exp_neighbors_1
    end

    test "produce correct cardinals", fixture do
      grid = Grid.from_squares(fixture.squares_1)
      act_cardinals =
        fixture.positions_1
        |> Enum.map(&(Grid.cardinals_of(grid, &1)))
      assert act_cardinals == fixture.exp_cardinals_1
    end
  end
end
