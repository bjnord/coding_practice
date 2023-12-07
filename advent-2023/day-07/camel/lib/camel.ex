defmodule Camel do
  @moduledoc """
  Documentation for `Camel`.
  """

  import Camel.Parser
  alias Camel.Hand
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
    hands = parse_input(input_file)
    ranks = Hand.ranks(hands)
    Hand.winnings(hands, ranks)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    hands =
      parse_input(input_file)
      |> Enum.map(&Hand.strengthen/1)
    ranks = Hand.ranks(hands)
    Hand.winnings(hands, ranks)
    |> IO.inspect(label: "Part 2 answer is")
  end
end
