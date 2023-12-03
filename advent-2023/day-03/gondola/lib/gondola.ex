defmodule Gondola do
  @moduledoc """
  Documentation for `Gondola`.
  """

  import Gondola.Parser
  alias Gondola.Schematic, as: Schematic
  import Snow.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    |> Schematic.adjacent_parts()
    |> Enum.map(fn part -> part.number end)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    |> Schematic.gear_ratios()
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
