defmodule Race.Parser do
  @moduledoc """
  Parsing for `Race`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of races (`{time, record}` tuples).
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of races (`{time, record}` tuples).

  ## Examples
      iex> parse_input_string("Time:      3  4\nDistance:  1  2\n")
      [{3, 1}, {4, 2}]
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.zip()
  end

  @doc ~S"""
  Parse an input line containing a label and list of numbers.

  Returns a list of integers.

  ## Examples
      iex> parse_line("Time:      3  4\n")
      [3, 4]
  """
  def parse_line(line) do
    line
    |> String.split()
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
  end
end
