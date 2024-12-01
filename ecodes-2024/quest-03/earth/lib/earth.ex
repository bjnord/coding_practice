defmodule Earth do
  @moduledoc """
  Documentation for `Earth`.
  """

  # alias Kingdom.Grid
  #
  # def dig(grid), do: dig(Grid.keys(grid), grid)
  #
  # def dig([], grid), do: grid
  # def dig(squares, grid) do
  #   squares = diggable_squares(squares, grid)
  #   grid = Enum.reduce(squares, grid, &(dig_square(&1, grid)))
  #   dig(squares, grid)
  # end
  #
  # defp diggable_squares(squares, grid) do
  #   Enum.filter(squares, fn square ->
  #     square_depth = Grid.get(grid, square)
  #     neighbor_depths = Grid.cardinals_of(grid, square)
  #                       |> Enum.map(&(Grid.get(grid, &1)))
  #     diggable_square?(square_depth, neighbor_depths)
  # end
  #
  # defp dig_square(square, grid) do
  #   Grid.get_and_update(grid, square, &(&1 + 1))
  #   |> elem(1)
  # end

  def diggable_square?(0, _neighbor_depths), do: false
  def diggable_square?(depth, neighbor_depths) do
    neighbor_depths
    |> Enum.all?(&(&1 >= depth))
  end
end
