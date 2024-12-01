defmodule Location.Parser do
  @moduledoc """
  Parsing for `Location`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a tuple with two location lists.
  """
  def parse_input(input_file) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a tuple with two location lists.

  ## Examples
      iex> parse_input_string("5   7\n1   3\n 11  9 \n")
      {[5, 1, 11], [7, 3, 9]}
  """
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.unzip()
  end

  @doc ~S"""
  Parse an input line.

  ## Parameters

  - `line`: input line containing a pair of location values

  Returns a tuple with the two location values.

  ## Examples
      iex> parse_line("5   7\n")
      {5, 7}
      iex> parse_line(" 11  9 \n")
      {11, 9}
  """
  def parse_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
