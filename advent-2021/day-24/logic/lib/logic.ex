defmodule Logic do
  @moduledoc """
  Documentation for Logic.
  """
  alias Logic.Parser, as: Parser
  alias Logic.Unit, as: Unit
  alias Submarine.CLI, as: CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = CLI.parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
    if Enum.member?(opts[:parts], 3), do: matchsticks(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Play an interactive game of "21 Matchsticks".
  """
  def matchsticks(input_file, opts) do
    File.read!(input_file)
    |> Parser.parse()
    |> Unit.run([], opts)
  end
end
