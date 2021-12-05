defmodule Hydrothermal do
  @moduledoc ~S"""
  Documentation for Hydrothermal.

  Terminology:
  - an "intersection" is a single point where two vent vectors of **different angles** cross
    - _e.g._ a horizontal vector crossing a vertical one
  - an "overlap" is a set of points shared by two vent vectors of **the same angle**
    - _e.g._ `2,2 -> 5,5` and `7,7 -> 4,4` overlap on `4,4` and `5,5`
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
    |> vent_intersections()
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
    |> Enum.reverse
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> vent_intersections()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Find count of all vent intersection points.
  """
  def vent_intersections(vents) do
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
      grid =
        if Map.has_key?(grid, {x, y}) do
          Map.replace!(grid, {x, y}, grid[{x, y}] + 1)
        else
          Map.put(grid, {x, y}, 1)
        end
      {grid, max(dim, max(x+1, y+1))}
    end)
  end

  @doc """
  Render grid map to text.
  """
  def render_grid_map({grid, dim}) do
    grid_map_points(dim)
    |> Enum.reduce([], fn (pos, chars) ->
      if Map.has_key?(grid, pos) do
        [?0 + Map.get(grid, pos) | chars]
      else
        [?. | chars]
      end
    end)
    |> Enum.reverse
    |> Enum.chunk_every(dim)
    |> Enum.map(fn chars -> to_string(chars) end)
    |> Enum.join("\n")
    |> (fn text -> "#{text}\n" end).()
  end
  defp grid_map_points(dim) do
    for y <- 0..dim-1 do
      for x <- 0..dim-1 do
        {x, y}
      end
    end
    |> List.flatten()
  end
end
