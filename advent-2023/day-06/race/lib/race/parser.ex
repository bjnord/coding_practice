defmodule Race.Parser do
  @moduledoc """
  Parsing for `Race`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of races (`{time, record}` tuples).
  """
  def parse_input(input_file, opts \\ []) do
    File.read!(input_file)
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse input as a block string.

  (This produces a different result depending on the puzzle part rules.
  See "Examples".)

  ## Parameters

  - `input` - block string containing puzzle input
  - `opts` - `part` keyword (1 or 2)

  Returns a list of races (`{time, record}` tuples).

  ## Examples
      iex> parse_input_string("Time:      3  4\nDistance:  1  2\n", part: 1)
      [{3, 1}, {4, 2}]
      iex> parse_input_string("Time:      3  4\nDistance:  1  2\n", part: 2)
      [{34, 12}]
  """
  def parse_input_string(input, opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> parse_line(line, opts) end)
    |> Enum.zip()
  end

  @doc ~S"""
  Parse an input line containing a label and list of numbers.

  (This produces a different result depending on the puzzle part rules.
  See "Examples".)

  ## Parameters

  - `line` - one line of puzzle input
  - `opts` - `part` keyword (1 or 2)

  Returns a list of integers.

  ## Examples
      iex> parse_line("Time:      3  4\n", part: 1)
      [3, 4]
      iex> parse_line("Time:      3  4\n", part: 2)
      [34]
  """
  def parse_line(line, opts \\ []) do
    if opts[:part] == 2 do
      line
      |> String.split(":")
      |> Enum.drop(1)
      |> Enum.map(fn numbers -> Regex.replace(~r/\s+/, numbers, "") end)
    else
      line
      |> String.split()
      |> Enum.drop(1)
    end
    |> Enum.map(&String.to_integer/1)
  end
end
