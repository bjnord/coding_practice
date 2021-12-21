defmodule Hydrothermal do
  @moduledoc ~S"""
  Documentation for Hydrothermal.
  """

  import Hydrothermal.Parser
  import Submarine
  import Submarine.CLI
  require Logger

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
    |> Enum.filter(&Hydrothermal.horiz_or_vert?/1)
    |> vent_overlaps()
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
    |> Enum.reverse()
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
  Find count of all vent overlap points.
  """
  def vent_overlaps(vents) do
    {grid, _} = grid_map(vents)
    Map.keys(grid)
    |> Enum.count(fn k -> grid[k] > 1 end)
  end

  @doc """
  Build square grid map with count of point occurrences.

  Returns `{grid, dim}` where
  - `grid` is a `Map`: keys are `{x, y}` tuples, values are integer counts
  - `dim` is the dimension of the grid (_e.g._ `dim=10` has coordinates in `0..9`)
  """
  def grid_map(vents) do
    vents
    |> Enum.flat_map(&Hydrothermal.to_points/1)
    |> Enum.reduce({Map.new(), 0}, fn ({x, y}, {grid, dim}) ->
      {
        Map.update(grid, {x, y}, 1, fn c -> c + 1 end),
        max(dim, max(x+1, y+1)),
      }
    end)
  end

  @doc """
  Render grid map to text.
  """
  def render_grid_map({grid, dim}) do
    grid_map_points(dim)
    |> Enum.reduce([], fn (pos, chars) ->
      case Map.get(grid, pos) do
        nil -> [?. | chars]
        count -> [?0 + count | chars]
      end
    end)
    |> Enum.reverse()
    |> Enum.chunk_every(dim)
    |> Enum.map(fn chars -> to_string(chars) end)
    |> Enum.join("\n")
    |> (fn text -> "#{text}\n" end).()
  end

  defp grid_map_points(dim) do
    for y <- 0..dim-1, x <- 0..dim-1 do
      {x, y}
    end
  end

  @doc """
  Is the given point outside the grid dimensions?

  ## Examples
      iex> Hydrothermal.out_of_bounds?({0, 0}, 10)
      false
      iex> Hydrothermal.out_of_bounds?({10, 0}, 10)
      true
  """
  def out_of_bounds?({x, y}, dim) do
    cond do
      x < 0 -> true
      x >= dim -> true
      y < 0 -> true
      y >= dim -> true
      true -> false
    end
  end
end
