defmodule Smoke.Parser do
  @moduledoc """
  Parsing for `Smoke`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of integer location lists (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of integer location lists (one per line).

  ## Examples
      iex> parse_input_string("8670\n5309\n") |> Enum.to_list()
      [[8, 6, 7, 0], [5, 3, 0, 9]]
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a list of locations.

  Returns an integer location list.

  ## Examples
      iex> parse_line("8670\n")
      [8, 6, 7, 0]
      iex> parse_line("5309\n")
      [5, 3, 0, 9]
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(fn b -> b - ?0 end)
  end
end
