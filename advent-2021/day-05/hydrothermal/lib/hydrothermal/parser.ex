defmodule Hydrothermal.Parser do
  @moduledoc """
  Parsing for `Hydrothermal`.
  """

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&Hydrothermal.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&Hydrothermal.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing vent coordinates..

  Returns list of from, to integer coordinate tuples

  ## Examples
      iex> Hydrothermal.Parser.parse_line("1,1 -> 1,3\n")
      [{1, 1}, {1, 3}]
      iex> Hydrothermal.Parser.parse_line("9,7 -> 7,7\n")
      [{9, 7}, {7, 7}]
  """
  def parse_line(line) do
    Regex.run(~r/^(\d+),(\d+)\s+->\s+(\d+),(\d+)/, line)
    |> (fn [_, x1, y1, x2, y2] ->
      [
        {String.to_integer(x1), String.to_integer(y1)},
        {String.to_integer(x2), String.to_integer(y2)},
      ]
    end).()
  end
end
