defmodule Hoof do
  @moduledoc """
  Documentation for `Hoof`.
  """

  import Hoof.Parser
  import History.CLI
  alias History.Grid

  @type grid_square() :: {{integer(), integer()}, integer()}

  @doc ~S"""
  Compute the total score (sum of all trailhead scores).
  """
  @spec score(Grid.t()) :: integer()
  def score(grid) do
    grid
    |> trailhead_scores()
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.sum()
  end

  @doc ~S"""
  Compute the trailhead scores.

  "a trailhead's **score** is the number of 9-height positions reachable
  from that trailhead via a hiking trail"
  """
  @spec trailhead_scores(Grid.t()) :: [{grid_square(), integer()}]
  def trailhead_scores(grid) do
    grid
    |> trailheads()
    |> Enum.map(&({&1, score(grid, &1)}))
  end

  defp trailheads(grid) do
    grid
    |> Grid.keys()
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == 0 end)
    |> Enum.sort()
  end

  defp score(grid, trailhead) do
    nines(grid, 1, trailhead)
    |> Enum.uniq()
    |> Enum.count()
  end

  # this finds all **grid squares** with elevation 9 that are reachable
  # from the trailhead -- the returned squares may have duplicates (a
  # given 9 might be reachable via more than one path)
  @spec nines(Grid.t(), integer(), grid_square()) :: [grid_square()]
  defp nines(_grid, 10, next_pos), do: [next_pos]
  defp nines(grid, elev, next_pos) do
    Grid.cardinals_of(grid, next_pos)
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == elev end)
    |> Enum.map(&(nines(grid, elev + 1, &1)))
    |> List.flatten()
  end

  @doc ~S"""
  Compute the total rating (sum of all trailhead ratings).
  """
  @spec rating(Grid.t()) :: integer()
  def rating(grid) do
    grid
    |> trailhead_ratings()
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.sum()
  end

  @doc ~S"""
  Compute the trailhead ratings.

  "A trailhead's rating is the **number of distinct hiking trails**
  which begin at that trailhead."
  """
  @spec trailhead_ratings(Grid.t()) :: [{grid_square(), integer()}]
  def trailhead_ratings(grid) do
    grid
    |> trailheads()
    |> Enum.map(&({&1, rating(grid, &1)}))
  end

  defp rating(grid, trailhead) do
    paths(grid, 1, nil, trailhead)
  end

  # this finds the **number of paths** from the trailhead which end at
  # elevation 9 -- `elev` is the **next** elevation we are seeking --
  # passing the previous position along prevents backtracking
  @spec paths(Grid.t(), integer(), grid_square() | nil, grid_square()) :: integer()
  defp paths(_grid, 10, _prev_pos, _next_pos), do: 1
  defp paths(grid, elev, prev_pos, next_pos) do
    Grid.cardinals_of(grid, next_pos)
    |> Enum.reject(fn pos -> pos == prev_pos end)
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == elev end)
    |> Enum.map(&(paths(grid, elev + 1, next_pos, &1)))
    |> Enum.sum()
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
    |> Hoof.score()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Hoof.rating()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
