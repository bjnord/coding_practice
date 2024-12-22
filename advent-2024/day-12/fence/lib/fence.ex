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
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
