defmodule Beam.Parser do
  @moduledoc """
  Parsing for `Beam`.
  """

  alias Beam.Contraption

  @doc ~S"""
  Parse the input file.

  Returns a `Contraption`.
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a `Contraption`.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_line/1)
    |> List.flatten()
    |> Contraption.from_tiles()
  end

  @doc ~S"""
  Parse an input line containing contraption mirror/splitter characters.

  ## Parameters

  `line` - the input line
  `y` - the y position (integer) of the input line

  Returns the characters on the input line and their positions, as a
  list of `{{y, x}, ch}` tuples.

  ## Examples
      iex> parse_line({".|.\\.\n", 1})
      [{{1, 1}, ?|}, {{1, 3}, 92}]
      iex> parse_line({"/.-..\n", 2})
      [{{2, 0}, ?/}, {{2, 2}, ?-}]
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
