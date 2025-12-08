defmodule Wire.Parser do
  @moduledoc """
  Parsing for `Wire`.
  """

  @type box_position() :: {integer(), integer(), integer()}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a junction box position list
  """
  @spec parse_input_file(String.t()) :: [box_position()]
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

  a junction box position list

  ## Examples
      iex> parse_input_string("2,3,5\n7,11,13")
      [{5, 3, 2}, {13, 11, 7}]
  """
  @spec parse_input_string(String.t()) :: [box_position()]
  def parse_input_string(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a junction box position.

  Note: The input is X,Y,Z but the parsed tuple will be `{z, y, x}`.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a tuple with the junction box position coordinates

  ## Examples
      iex> parse_line("2,3,5\n")
      {5, 3, 2}
      iex> parse_line("7,11,13\n")
      {13, 11, 7}
  """
  @spec parse_line(String.t()) :: box_position()
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x, y, z] -> {z, y, x} end)
  end
end
