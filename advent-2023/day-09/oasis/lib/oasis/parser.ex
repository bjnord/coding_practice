defmodule Oasis.Parser do
  @moduledoc """
  Parsing for `Oasis`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of charlists (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of integer lists (one per line).

  ## Examples
      iex> parse_input_string("0 3 6 9 12 15\n1 3 6 10 15 21\n") |> Enum.to_list()
      [[0, 3, 6, 9, 12, 15], [1, 3, 6, 10, 15, 21]]
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing environmental readings.

  Returns a list of integers.

  ## Examples
      iex> parse_line("0 3 6 9 12 15\n")
      [0, 3, 6, 9, 12, 15]
      iex> parse_line("1 3 6 10 15 21\n")
      [1, 3, 6, 10, 15, 21]
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
