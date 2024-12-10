defmodule Hoof do
  @moduledoc """
  Documentation for `Hoof`.
  """

  import Hoof.Parser
  import History.CLI
  alias History.Grid

  def scores(grid) do
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

  defp score(_grid, _trailhead) do
    1
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
