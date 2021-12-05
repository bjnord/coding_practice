defmodule Hydrothermal do
  @moduledoc """
  Documentation for Hydrothermal.
  """

  import Hydrothermal.Parser
  import Submarine
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
    input_file
    |> parse_input(opts)
    |> horiz_or_vert_overlaps()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Find count of all horizontal or vertical vent intersection points.
  """
  def horiz_or_vert_overlaps(vents) do
    grid = vents
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
      iex> Hydrothermal.to_points([{6, 1}, {2, 5}])
      [{6, 1}, {5, 2}, {4, 3}, {3, 4}, {2, 5}]
  """
  def to_points([{x1, y1}, {x2, y2}]) do
    dx = step_delta(x1, x2)
    dy = step_delta(y1, y2)
    1..1_000_000
    |> Enum.reduce_while({[], {x1, y1}}, fn (_i, {points, {x, y}}) ->
      if {x, y} == {x2, y2} do
        {:halt, [{x, y} | points]}
      else
        {:cont, {[{x, y} | points], {x + dx, y + dy}}}
      end
    end)
    |> Enum.reverse
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> vent_overlaps()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Find count of all vent intersection points.
  """
  def vent_overlaps(vents) do
    grid = vents
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
  end
end
