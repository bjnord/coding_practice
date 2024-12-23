defmodule Fence do
  @moduledoc """
  Documentation for `Fence`.
  """

  import Fence.Parser
  import History.CLI
  alias History.Grid

  def prices(grid) do
    areas_perimeters(grid)
    |> Enum.reduce(0, fn {_plant, {area, perim}}, acc ->
      acc + area * perim
    end)
  end

  # returns list of `{plant, {area, perimeter}}`
  def areas_perimeters(grid) do
    grid.meta.regions
    |> Enum.map(&(region_area_perimeter(grid, &1)))
  end

  defp region_area_perimeter(grid, {plant, positions}) do
    {plant, area_perimeter(grid, {plant, positions})}
  end

  defp area_perimeter(grid, {plant, positions}) do
    {
      area(positions),
      perimeter(grid, {plant, positions}),
    }
  end

  def area(positions), do: Enum.count(positions)

  def perimeter(grid, {plant, positions}) do
    positions
    |> Enum.map(&(fence_count(grid, &1, plant)))
    |> Enum.sum()
  end

  def fence_count(grid, pos, plant) do
    neighbors = Grid.cardinals_of(grid, pos)
    neighbors
    |> Enum.reduce(border_fence_count(neighbors), fn npos, acc ->
      if Grid.get(grid, npos) != plant do
        acc + 1
      else
        acc
      end
    end)
  end

  # fences at the edges of the grid (no neighbor beyond)
  defp border_fence_count(neighbors), do: 4 - length(neighbors)

  def bulk_prices(grid) do
    areas_sides(grid)
    |> Enum.reduce(0, fn {_plant, {area, side}}, acc ->
      acc + area * side
    end)
  end

  # returns list of `{plant, {area, sides}}`
  def areas_sides(grid) do
    grid.meta.regions
    |> Enum.map(&(region_area_sides(grid, &1)))
  end

  defp region_area_sides(grid, {plant, positions}) do
    {plant, area_sides(grid, {plant, positions})}
  end

  defp area_sides(grid, {plant, positions}) do
    {
      area(positions),
      sides(grid, {plant, positions}),
    }
  end

  def sides(grid, {plant, positions}) do
    positions
    |> Enum.flat_map(&(position_sides(grid, &1, plant)))
    |> fence_sides()
  end

  def fence_sides(fences) do
    horiz_sides(fences) + vert_sides(fences)
  end

  defp horiz_sides(fences) do
    fences
    |> Enum.filter(fn {_pos, ch} -> (ch == ?-) || (ch == ?=) end)
    |> Enum.sort_by(fn {{y, x}, _ch} -> {y, x} end)
    |> sides_of(&horiz_cmp/1)
  end

  def horiz_cmp([{{_ny, _nx}, _nch}]), do: :side
  def horiz_cmp([{{y, x}, ch}, {{ny, nx}, nch}]) do
    cond do
      ch != nch ->                       :side
      (ny == y) && (abs(nx - x) == 2) -> :more_side
      true ->                            :side
    end
  end

  defp vert_sides(fences) do
    fences
    |> Enum.filter(fn {_pos, ch} -> (ch == ?|) || (ch == ?I) end)
    |> Enum.sort_by(fn {{y, x}, _ch} -> {x, y} end)
    |> sides_of(&vert_cmp/1)
  end

  def vert_cmp([{{_ny, _nx}, _nch}]), do: :side
  def vert_cmp([{{y, x}, ch}, {{ny, nx}, nch}]) do
    cond do
      ch != nch ->                       :side
      (nx == x) && (abs(ny - y) == 2) -> :more_side
      true ->                            :side
    end
  end

  defp sides_of(fences, f) do
    fences
    |> Enum.chunk_every(2, 1)
    |> Enum.map(&(f.(&1)))
    |> Enum.count(&(&1 == :side))
  end

  # returns list of `{plant, [{pos, ch}]}`
  def fence_squares(grid) do
    grid.meta.regions
    |> Enum.map(&(region_fence_squares(grid, &1)))
  end

  defp region_fence_squares(grid, {plant, positions}) do
    positions
    |> Enum.flat_map(&(position_sides(grid, &1, plant)))
    |> then(&({plant, &1}))
  end

  # returns list of fence {pos, ch}
  def position_sides(grid, pos, plant) do
    neighbors = Grid.cardinals_of(grid, pos, oob: true)
    neighbors
    |> Enum.reduce([], fn npos, acc ->
      if Grid.get(grid, npos) != plant do
        [side_of(pos, npos) | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end

  defp side_of({y, x}, {ny, nx}) do
    {dy, dx} = {ny - y, nx - x}
    {
      {double(y) + dy, double(x) + dx},
      fence_of(dy, dx),
    }
  end

  defp double(n), do: n * 2 + 1

  defp fence_of(dy, 0) when dy > 0, do: ?=
  defp fence_of(_dy, 0), do: ?-
  defp fence_of(0, dx) when dx > 0, do: ?I
  defp fence_of(0, _dx), do: ?|

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Fence.prices()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Fence.bulk_prices()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
