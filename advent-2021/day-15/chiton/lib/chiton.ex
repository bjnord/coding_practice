defmodule Chiton do
  @moduledoc """
  Documentation for Chiton.
  """

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
  # FIXME this makes assumptions about the dimensions of the input
  def part1(input_file) do
    # What is the lowest total risk of any path from the top left to the
    # bottom right?
    distances =
      File.read!(input_file)
      |> Chiton.Cave.new()
      |> Chiton.Cave.distances()
    distances[{99, 99}]
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Chiton.Cave.new()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
