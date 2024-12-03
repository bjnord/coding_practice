defmodule Smoke.Parser do
  @moduledoc """
  Parsing for `Smoke`.
  """

  @doc ~S"""
  Parse the input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of integer location lists
  """
  @spec parse_input_file(String.t()) :: [list(integer())]
  def parse_input_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of integer location lists

  ## Examples
      iex> parse_input_string("8670\n5309\n") |> Enum.to_list()
      [[8, 6, 7, 0], [5, 3, 0, 9]]
  """
  @spec parse_input_string(String.t()) :: [list(integer())]
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line.

  ## Parameters

  - `line`: a puzzle input line

  ## Returns

  an integer location list

  ## Examples
      iex> parse_line("8670\n")
      [8, 6, 7, 0]
      iex> parse_line("5309\n")
      [5, 3, 0, 9]
  """
  @spec parse_line(String.t()) :: [integer()]
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(fn b -> b - ?0 end)
  end
end
