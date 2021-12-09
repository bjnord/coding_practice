defmodule Segment do
  @moduledoc """
  Documentation for Segment.
  """

  import Segment.Parser
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
  def part1(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> Enum.map(&Segment.count_unique/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Count number of unique output values (digits 1, 4, 7, 8).
  """
  def count_unique({_signal_patterns, output_values}) do
    output_values
    |> Enum.count(fn ov ->
      case length(ov) do
        2 -> true  # digit 1
        3 -> true  # digit 7
        4 -> true  # digit 4
        7 -> true  # digit 8
        _ -> false
      end
    end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> Enum.map(&Segment.Decoder.digits_of_note/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
