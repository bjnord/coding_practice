defmodule Location.Parser do
  @moduledoc """
  Parsing for `Location`.
  """

  @doc ~S"""
  Parse the input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a tuple with two location lists
  """
  @spec parse_input_file(String.t()) :: {[integer()], [integer()]}
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a tuple with two location lists

  ## Examples
      iex> parse_input_string("5   7\n1   3\n 11  9 \n")
      {[5, 1, 11], [7, 3, 9]}
  """
  @spec parse_input_string(String.t()) :: {[integer()], [integer()]}
  def parse_input_string(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.unzip()
  end

  @doc ~S"""
  Parse an input line.

  ## Parameters

  - `line`: a puzzle input line

  ## Returns

  a tuple with the two location values

  ## Examples
      iex> parse_line("5   7\n")
      {5, 7}
      iex> parse_line(" 11  9 \n")
      {11, 9}
  """
  @spec parse_line(String.t()) :: {integer(), integer()}
  def parse_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
