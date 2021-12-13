defmodule Origami do
  @moduledoc """
  Documentation for Origami.
  """

  import Origami.Paper
  import Submarine.CLI

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
    # "How many dots are visible after completing just the first fold
    # instruction on your transparent paper?"
    {paper, instructions} =
      File.read!(input_file)
      |> parse_input_string()
    paper
    |> fold(List.first(instructions))
    |> n_points()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> parse_input_string()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
