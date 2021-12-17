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
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts) do
    mtr_func =
      if opts[:times] do
        &Chiton.Cave.timed_min_total_risk/2
      else
        &Chiton.Cave.min_total_risk/2
      end
    # What is the lowest total risk of any path from the top left to the
    # bottom right?
    File.read!(input_file)
    |> Chiton.Cave.new()
    |> mtr_func.(opts[:verbose])
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts) do
    mtr_func =
      if opts[:times] do
        &Chiton.Cave.timed_min_total_risk/2
      else
        &Chiton.Cave.min_total_risk/2
      end
    # "Using the full [5x] map, what is the lowest total risk of any path
    # from the top left to the bottom right?"
    File.read!(input_file)
    |> Chiton.Cave.new(scale: 5)
    |> mtr_func.(opts[:verbose])
    |> IO.inspect(label: "Part 2 answer is")
  end
end
