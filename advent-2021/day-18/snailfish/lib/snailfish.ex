defmodule Snailfish do
  @moduledoc """
  Documentation for Snailfish.
  """

  alias Snailfish.Smath, as: Smath
  import Submarine.CLI

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
  def part1(input_file, _opts \\ []) do
    # "Add up all of the snailfish numbers [...] in the order they
    # appear. What is the magnitude of the final sum?"
    File.read!(input_file)
    |> String.split("\n", trim: true)
    |> Smath.add()
    |> Smath.magnitude()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, _opts \\ []) do
    # "What is the largest magnitude of any sum of two different snailfish
    # numbers from the homework assignment?"
    File.read!(input_file)
    |> String.split("\n", trim: true)
    |> Smath.largest_magnitude()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
