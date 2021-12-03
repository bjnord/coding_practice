defmodule Diagnostic do
  @moduledoc """
  Documentation for Diagnostic.
  """

  import Diagnostic.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    {gam, eps} = input_file
                 |> parse_input(opts)
                 |> compute_rates
    IO.inspect(gam * eps, label: "Part 1 answer is")
  end

  @doc """
  Compute gamma and epsilon rates.

  FIXME add Return and Examples
  """
  def compute_rates(_lines) do
    {3, 7}  # TODO
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    {gam, eps} = input_file
                 |> parse_input(opts)
                 |> compute_rates
    IO.inspect(gam * eps, label: "Part 2 answer is NOT")
  end
end
