defmodule Bingo do
  @moduledoc """
  Documentation for Bingo.
  """

  import Bingo.CLI

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
    {balls, boards} = input_file
                      |> File.read!
                      |> parse_input
    IO.puts("Part 1 answer is TODO")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    IO.puts("Part 2 answer is TODO")
  end
end
