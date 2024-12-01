defmodule Location.Parser do
  @moduledoc """
  Parsing for `Location`.
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

  Returns a list of charlists (one per line).

  ## Examples
      iex> parse_input_string("5   7\n11  9\n") |> Enum.to_list()
      [{5, 7}, {11, 9}]
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a navigation subsystem entry.

  Returns a charlist.

  ## Examples
      iex> parse_line("5   7\n")
      {5, 7}
      iex> parse_line("11  9\n")
      {11, 9}
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(~r{\s+})
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
