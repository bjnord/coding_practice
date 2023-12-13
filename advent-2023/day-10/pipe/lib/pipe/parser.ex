defmodule Pipe.Parser do
  @moduledoc """
  Parsing for `Pipe`.
  """

  alias Pipe.Maze

  @doc ~S"""
  Parse the input file.

  Returns a `Maze`.
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a `Maze`.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_line/1)
    |> List.flatten()
    |> Maze.from_tiles()
  end

  @doc ~S"""
  Parse an input line containing maze pipe characters.

  ## Parameters

  `line` - the input line
  `y` - the y position (integer) of the input line

  Returns the characters on the input line and their positions, as a
  list of `{{y, x}, ch}` tuples.

  ## Examples
      iex> parse_line({".S-7.\n", 1})
      [{{1, 1}, ?S}, {{1, 2}, ?-}, {{1, 3}, ?7}]
      iex> parse_line({".|.|.\n", 2})
      [{{2, 1}, ?|}, {{2, 3}, ?|}]
  """
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reject(fn {ch, _x} -> ch == ?. end)
    |> Enum.map(fn {ch, x} -> {{y, x}, ch} end)
  end
end
