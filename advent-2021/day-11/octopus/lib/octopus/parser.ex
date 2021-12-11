defmodule Octopus.Parser do
  @moduledoc """
  Parsing for `Octopus`.
  """

  use Bitwise

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, opts \\ []) do
    input_file
    |> File.read!
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse input as a block string.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Octopus.Parser.parse_line/1)
    |> List.to_tuple()
  end

  @doc ~S"""
  Parse an input line containing a set of digits.

  Returns tuple of integer digit values.

  ## Examples
      iex> Octopus.Parser.parse_line("5483143223\n")
      {5, 4, 8, 3, 1, 4, 3, 2, 2, 3}
      iex> Octopus.Parser.parse_line("5283751526\n")
      {5, 2, 8, 3, 7, 5, 1, 5, 2, 6}
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(fn d -> d - ?0 end)
    |> List.to_tuple()
  end
end
