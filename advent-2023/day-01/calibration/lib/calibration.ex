defmodule Calibration do
  @moduledoc """
  Documentation for `Calibration`.
  """

  @doc """
  Calculate calibration value.

  ## Examples

      iex> Calibration.value('ab1c2de')
      12

  """
  def value(chars) do
    first = chars |> Enum.find(fn (ch) -> (ch >= ?0) && (ch <= ?9) end)
    last = chars |> Enum.reverse() |> Enum.find(fn (ch) -> (ch >= ?0) && (ch <= ?9) end)
    ((first - ?0) * 10) + (last - ?0)
  end

  alias Calibration.Parser, as: Parser
  alias Snow.CLI, as: CLI

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
    File.read!(input_file)
    |> Parser.parse()
    |> Enum.map(&Calibration.value/1)
    |> Enum.sum()
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
