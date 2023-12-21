defmodule Steps do
  @moduledoc """
  Documentation for `Steps`.
  """

  import Steps.Parser
  alias Steps.Garden
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
    garden = parse_input(input_file)
    steps = if garden.size.y <= 10, do: 6, else: 64
    Garden.reachable(garden, steps)
    |> IO.inspect(label: "Part 1 answer (#{steps} steps) is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
