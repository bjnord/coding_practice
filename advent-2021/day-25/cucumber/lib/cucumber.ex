defmodule Cucumber do
  @moduledoc """
  Documentation for Cucumber.
  """

  alias Cucumber.Herd, as: Herd
  alias Cucumber.Parser, as: Parser
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
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # "What is the first step on which no sea cucumbers move?"
    File.read!(input_file)
    |> Herd.new()
    |> Herd.blocked_step()
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
end
