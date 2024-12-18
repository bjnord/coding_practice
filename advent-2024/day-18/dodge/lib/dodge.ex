defmodule Dodge do
  @moduledoc """
  Documentation for `Dodge`.
  """

  alias Dodge.Graph
  import Dodge.Parser
  import History.CLI

  def blocking_position(input, size) do
    fence(input, size, 0, input_length(input))
    |> position_at(input)
  end

  defp input_length(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count()
  end

  defp position_at(n, input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.at(n)
  end

  def fence(_input, _size, min, max) when min == max, do: min
  def fence(_input, _size, min, max) when min == max - 1, do: min
  def fence(input, size, min, max) do
    length = div(min + max, 2)
    if lowest_cost(input, size, length) == nil do
      fence(input, size, min, length)
    else
      fence(input, size, length, max)
    end
  end

  def lowest_cost(input, size, length) do
    input
    |> parse_input_string(size, length)
    |> Graph.new()
    |> Graph.lowest_cost()
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
    parse_input_file(input_path, {71, 71}, 1024)
    |> Graph.new()
    |> Graph.lowest_cost()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    File.read!(input_path)
    |> Dodge.blocking_position({71, 71})
    |> IO.inspect(label: "Part 2 answer is")
  end
end
