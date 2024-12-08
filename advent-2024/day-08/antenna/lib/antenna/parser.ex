defmodule Antenna.Parser do
  @moduledoc """
  Parsing for `Antenna`.
  """

  @type antenna() :: {{integer(), integer()}, char()}
  @type antenna_chart() :: {[antenna()], integer(), integer()}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  an antenna chart
  """
  @spec parse_input_file(String.t()) :: antenna_chart()
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  an antenna chart

  ## Examples
      iex> parse_input_string(".0.A\n0.A.\n")
      {[{{0, 1}, ?0}, {{0, 3}, ?A}, {{1, 0}, ?0}, {{1, 2}, ?A}], {2, 4}}
  """
  @spec parse_input_string(String.t()) :: antenna_chart()
  def parse_input_string(input) do
    lines = input
            |> String.split("\n", trim: true)
            |> Enum.with_index()
            |> Enum.map(&parse_line/1)
    height = length(lines)
    width = elem(hd(lines), 1)
    antennas = lines
               |> Enum.map(&(elem(&1, 0)))
               |> List.flatten()
    {antennas, {height, width}}
  end

  @doc ~S"""
  Parse an input line containing antenna positions.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  antennas and line width

  ## Examples
      iex> parse_line({"#0.A\n", 0})
      {[{{0, 1}, ?0}, {{0, 3}, ?A}], 4}
      iex> parse_line({"0.A#.\n", 1})
      {[{{1, 0}, ?0}, {{1, 2}, ?A}], 5}
  """
  @spec parse_line({String.t(), integer()}) :: {[antenna()], integer()}
  def parse_line({line, y}) do
    chars = String.trim_trailing(line)
            |> String.to_charlist()
    width = length(chars)
    antennas = chars
               |> Enum.with_index()
               |> Enum.reject(fn {ch, _x} ->
                 ch == ?. || ch == ?#
               end)
               |> Enum.map(fn {ch, x} -> {{y, x}, ch} end)
    {antennas, width}
  end
end
