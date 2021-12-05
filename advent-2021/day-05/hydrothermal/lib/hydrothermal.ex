defmodule Hydrothermal do
  @moduledoc """
  Documentation for Hydrothermal.
  """

  import Hydrothermal.Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    grid = input_file
           |> parse_input(opts)
           |> Enum.filter(&Hydrothermal.horiz_or_vert?/1)
           |> Enum.flat_map(&Hydrothermal.to_points/1)
           |> Enum.reduce(Map.new(), fn (p, grid) ->
             if Map.has_key?(grid, p) do
               Map.replace!(grid, p, grid[p] + 1)
             else
               Map.put(grid, p, 1)
             end
           end)
    Map.keys(grid)
    |> Enum.count(fn k -> grid[k] > 1 end)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Is the given vent horizontal or vertical?

  ## Examples
      iex> Hydrothermal.horiz_or_vert?([{1, 1}, {1, 3}])
      true
      iex> Hydrothermal.horiz_or_vert?([{1, 1}, {3, 1}])
      true
      iex> Hydrothermal.horiz_or_vert?([{1, 1}, {3, 3}])
      false
  """
  def horiz_or_vert?([{x1, y1}, {x2, y2}]) do
    (x1 == x2) || (y1 == y2)
  end

  @doc """
  Find the points along the vent.

  ## Examples
      iex> Hydrothermal.to_points([{1, 1}, {1, 3}])
      [{1, 1}, {1, 2}, {1, 3}]
      iex> Hydrothermal.to_points([{4, 2}, {2, 2}])
      [{4, 2}, {3, 2}, {2, 2}]
  """
  def to_points([{x1, y1}, {x2, y2}]) do
    cond do
      x1 == x2 ->
        y1..y2
        |> Enum.map(fn y -> {x1, y} end)
      y1 == y2 ->
        x1..x2
        |> Enum.map(fn x -> {x, y1} end)
    end
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    IO.inspect(nil, label: "Part 2 answer is")
  end
end
