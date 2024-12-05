defmodule Reactor.Parser do
  @moduledoc """
  Parsing for `Reactor`.
  """

  @opaque streamable(t) :: list(t) | Enum.t | Enumerable.t

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of reports
  """
  @spec parse_input_file(String.t()) :: streamable([integer()])
  def parse_input_file(path) do
    path
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of reports
  """
  @spec parse_input_string(String.t()) :: streamable([integer()])
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a reactor report.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a list of reactor levels

  ## Examples
      iex> parse_line("1 2 3 5 8\n")
      [1, 2, 3, 5, 8]
      iex> parse_line("11 8 5 3 2\n")
      [11, 8, 5, 3, 2]
  """
  @spec parse_line(String.t()) :: [integer()]
  def parse_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
