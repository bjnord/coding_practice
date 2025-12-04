defmodule Roll do
  @moduledoc """
  Documentation for `Roll`.
  """

  import Decor.CLI
  alias Decor.Grid
  import Roll.Parser

  @doc """
  Find grid positions of rolls with fewer than four adjacent rolls.
  """
  def accessible_positions(grid) do
    Grid.keys(grid)
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == ?@ end)
    |> Enum.filter(fn pos -> accessible_roll?(grid, pos) end)
  end

  @doc """
  Does the roll at this grid position have fewer than four adjacent rolls?
  """
  def accessible_roll?(grid, pos) do
    Grid.neighbors_of(grid, pos)
    |> Enum.count(fn pos -> Grid.get(grid, pos) == ?@ end)
    |> then(fn count -> count < 4 end)
  end

  @doc """
  Remove as many accessible rolls as possible from the grid.
  """
  def remove_rolls(grid) do
    accessible_pos = accessible_positions(grid)
    remove_rolls_step(grid, accessible_pos)
  end

  defp remove_rolls_step(grid, []), do: grid
  defp remove_rolls_step(grid, positions) do
    grid =
      Enum.reduce(positions, grid, fn pos, acc ->
        Grid.put(acc, pos, ?x)
      end)
    accessible_pos = accessible_positions(grid)
    remove_rolls_step(grid, accessible_pos)
  end

  @doc """
  Find grid positions of removed rolls.
  """
  def removed_positions(grid) do
    Grid.keys(grid)
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == ?x end)
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
    |> accessible_positions()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> remove_rolls()
    |> removed_positions()
    |> Enum.count()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
