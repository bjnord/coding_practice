defmodule Reactor.Parser do
  @moduledoc """
  Parsing for `Reactor`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of reports (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of reports (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a reactor report.

  Returns a list of integers.

  ## Examples
      iex> parse_line("1 2 3 5 8\n")
      [1, 2, 3, 5, 8]
      iex> parse_line("11 8 5 3 2\n")
      [11, 8, 5, 3, 2]
  """
  def parse_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
