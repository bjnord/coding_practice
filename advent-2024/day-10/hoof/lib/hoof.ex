defmodule Hoof do
  @moduledoc """
  Documentation for `Hoof`.
  """

  import Hoof.Parser
  import History.CLI
  alias History.Grid

  def score(grid) do
    grid
    |> trailhead_scores()
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.sum()
  end

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

  defp nines(_grid, 10, next_pos), do: [next_pos]
  defp nines(grid, elev, next_pos) do
    Grid.cardinals_of(grid, next_pos)
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == elev end)
    |> Enum.map(&(nines(grid, elev + 1, &1)))
    |> List.flatten()
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
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
