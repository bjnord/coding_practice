defmodule Polymer do
  @moduledoc """
  Documentation for Polymer.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Polymer.hello()
      :world

  """
  def hello do
    :world
  end

  import Polymer.Parser
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
    File.read!(input_file)
    |> parse_input_string()
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
