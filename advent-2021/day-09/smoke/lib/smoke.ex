defmodule Smoke do
  @moduledoc """
  Documentation for `Smoke`.
  """

  import Smoke.FloorMap
  import Smoke.Parser
  import Submarine.CLI

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
    |> build_floor_map()
    |> low_points()
    |> risk_level_sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> build_floor_map()
    |> largest_3_basin_counts()
    |> Enum.reduce(1, fn (count, acc) -> acc * count end)
    |> IO.inspect(label: "Part 2 answer is")
  end
end
