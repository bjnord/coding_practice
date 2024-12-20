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

  def areas_perimeters(grid) do
    Grid.keys(grid)
    |> Enum.reduce(%{}, fn pos, acc ->
      plant = Grid.get(grid, pos)
      {areas, perims} = Map.get(acc, plant, {0, 0})
      new_val = {
        areas + 1,
        perims + perimeters_of(grid, pos, plant),
      }
      Map.put(acc, plant, new_val)
    end)
  end

  def perimeters_of(grid, pos, plant) do
    neighbors = Grid.cardinals_of(grid, pos)
    neighbors
    |> Enum.reduce(4 - length(neighbors), fn npos, acc ->
      if Grid.get(grid, npos) != plant do
        acc + 1
      else
        acc
      end
    end)
  end

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
    nil  # TODO
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
