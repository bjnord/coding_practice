defmodule Smoke.Parser do
  @moduledoc """
  Parsing for `Smoke`.
  """

  @opaque streamable(t) :: list(t) | Enum.t | Enumerable.t

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a 2D location height list
  """
  @spec parse_input_file(String.t()) :: streamable([[integer()]])
  def parse_input_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a 2D location height list

  ## Examples
      iex> parse_input_string("8670\n5309\n") |> Enum.to_list()
      [[8, 6, 7, 0], [5, 3, 0, 9]]
  """
  @spec parse_input_string(String.t()) :: streamable([[integer()]])
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing location heights.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a location height list

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
