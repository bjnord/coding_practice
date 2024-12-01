defmodule EarthTest do
  use ExUnit.Case
  doctest Earth

  import Earth
  alias Kingdom.Grid

  describe "examples" do
    setup do
      [
        diggable_squares: [
          {
            {0, [0, 0]},
            false,
          },
          {
            {0, [1, 1, 1, 0]},
            false,
          },
          {
            {1, [0, 1, 1, 1]},
            false,
          },
          {
            {1, [1, 1, 1, 1]},
            true,
          },
          {
            {1, [1, 1, 1, 2]},
            true,
          },
          {
            {2, [1, 2, 2, 1]},
            false,
          },
          {
            {2, [2, 2, 2, 2]},
            true,
          },
        ],
        example_grid: %Grid{
          size: %{y: 7, x: 10},
          squares: %{
            {0, 0} => 0, {0, 1} => 0, {0, 2} => 0, {0, 3} => 0, {0, 4} => 0,
            {0, 5} => 0, {0, 6} => 0, {0, 7} => 0, {0, 8} => 0, {0, 9} => 0,
            {1, 0} => 0, {1, 1} => 0, {1, 2} => 1, {1, 3} => 1, {1, 4} => 1,
            {1, 5} => 0, {1, 6} => 1, {1, 7} => 1, {1, 8} => 0, {1, 9} => 0,
            {2, 0} => 0, {2, 1} => 0, {2, 2} => 0, {2, 3} => 1, {2, 4} => 1,
            {2, 5} => 1, {2, 6} => 1, {2, 7} => 0, {2, 8} => 0, {2, 9} => 0,
            {3, 0} => 0, {3, 1} => 0, {3, 2} => 1, {3, 3} => 1, {3, 4} => 1,
            {3, 5} => 1, {3, 6} => 1, {3, 7} => 1, {3, 8} => 0, {3, 9} => 0,
            {4, 0} => 0, {4, 1} => 0, {4, 2} => 1, {4, 3} => 1, {4, 4} => 1,
            {4, 5} => 1, {4, 6} => 1, {4, 7} => 1, {4, 8} => 0, {4, 9} => 0,
            {5, 0} => 0, {5, 1} => 0, {5, 2} => 0, {5, 3} => 1, {5, 4} => 1,
            {5, 5} => 1, {5, 6} => 1, {5, 7} => 0, {5, 8} => 0, {5, 9} => 0,
            {6, 0} => 0, {6, 1} => 0, {6, 2} => 0, {6, 3} => 0, {6, 4} => 0,
            {6, 5} => 0, {6, 6} => 0, {6, 7} => 0, {6, 8} => 0, {6, 9} => 0,
          }
        },
        exp_dig_depths: [
          [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
          [ 0, 0, 1, 1, 1, 0, 1, 1, 0, 0 ],
          [ 0, 0, 0, 1, 2, 1, 1, 0, 0, 0 ],
          [ 0, 0, 1, 2, 3, 2, 2, 1, 0, 0 ],
          [ 0, 0, 1, 2, 2, 2, 2, 1, 0, 0 ],
          [ 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 ],
          [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
        ],
        exp_dug_sum: 35,
        exp_diagonal_dig_depths: [
          [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
          [ 0, 0, 1, 1, 1, 0, 1, 1, 0, 0 ],
          [ 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 ],
          [ 0, 0, 1, 1, 2, 2, 1, 1, 0, 0 ],
          [ 0, 0, 1, 1, 2, 2, 1, 1, 0, 0 ],
          [ 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 ],
          [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
        ],
        exp_diagonal_dug_sum: 29,
      ]
    end

    test "detects correct diggable squares", fixture do
      act_diggable_squares =
        fixture.diggable_squares
        |> Enum.map(fn {{depth, neighbor_depths}, _is} ->
          is = diggable_square?(depth, neighbor_depths)
          {{depth, neighbor_depths}, is}
        end)
      assert act_diggable_squares == fixture.diggable_squares
    end

    test "produces correct dug grid (cardinals)", fixture do
      dug_grid = dig(fixture.example_grid)
      act_dig_depths =
        0..(dug_grid.size.y - 1)
        |> Enum.map(fn y ->
          0..(dug_grid.size.x - 1)
          |> Enum.map(fn x -> Grid.get(dug_grid, {y, x}) end)
        end)
      assert act_dig_depths == fixture.exp_dig_depths
      act_dug_sum =
        Grid.values(dug_grid)
        |> Enum.sum()
      assert act_dug_sum == fixture.exp_dug_sum
    end

    test "produces correct dug grid (diagonals)", fixture do
      dug_grid = diagonal_dig(fixture.example_grid)
      act_diagonal_dig_depths =
        0..(dug_grid.size.y - 1)
        |> Enum.map(fn y ->
          0..(dug_grid.size.x - 1)
          |> Enum.map(fn x -> Grid.get(dug_grid, {y, x}) end)
        end)
      assert act_diagonal_dig_depths == fixture.exp_diagonal_dig_depths
      act_diagonal_dug_sum =
        Grid.values(dug_grid)
        |> Enum.sum()
      assert act_diagonal_dug_sum == fixture.exp_diagonal_dug_sum
    end
  end
end
