defmodule Xmas.GridTest do
  use ExUnit.Case
  doctest Xmas.Grid, import: true

  alias Xmas.Grid

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
          }
        },
      ]
    end

    test "produce correct grids", fixture do
      act_grid = Grid.from_squares(fixture.squares_1)
      assert act_grid == fixture.exp_grid_1
    end
  end
end
