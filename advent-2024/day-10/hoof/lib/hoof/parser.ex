defmodule Hoof.Parser do
  @moduledoc """
  Parsing for `Hoof`.
  """

  alias History.Grid

  @type puzzle_square() :: {{integer(), integer()}, char()}

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a `Grid`
  """
  @spec parse_input_file(String.t()) :: Grid.t()
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

  a `Grid`
  """
  @spec parse_input_string(String.t()) :: Grid.t()
  def parse_input_string(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(&parse_line/1)
    |> Grid.from_squares()
  end

  @doc ~S"""
  Parse an input line containing puzzle square characters.

  ## Parameters

  - `line`: the puzzle input line
  - `y`: the y position of the input line

  ## Returns

  the non-empty puzzle square characters and their positions, as a list of
  `{{y, x}, ch}` tuples

  ## Examples
      iex> parse_line({"02431\n", 0})
      [{{0, 0}, 0}, {{0, 1}, 2}, {{0, 2}, 4}, {{0, 3}, 3}, {{0, 4}, 1}]
      iex> parse_line({"..9.8\n", 1})
      [{{1, 2}, 9}, {{1, 4}, 8}]
  """
  @spec parse_line({String.t(), integer()}) :: [puzzle_square()]
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reject(fn {ch, _x} -> ch == ?. end)
    |> Enum.map(fn {ch, x} -> {{y, x}, ch - ?0} end)
  end
end
