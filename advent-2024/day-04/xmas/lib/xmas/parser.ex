defmodule Xmas.Parser do
  @moduledoc """
  Parsing for `Xmas`.
  """

  alias Xmas.Grid

  @doc ~S"""
  Parse the input file.

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
  Parse input as a block string.

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

  - `line`: the input line
  - `y`: the y position (integer) of the input line

  Returns the puzzle square characters and their positions, as a list of
  `{{y, x}, ch}` tuples.

  ## Examples
      iex> parse_line({".XMAS\n", 0})
      [{{0, 0}, ?.}, {{0, 1}, ?X}, {{0, 2}, ?M}, {{0, 3}, ?A}, {{0, 4}, ?S}]
      iex> parse_line({"SA.X.\n", 1})
      [{{1, 0}, ?S}, {{1, 1}, ?A}, {{1, 2}, ?.}, {{1, 3}, ?X}, {{1, 4}, ?.}]
  """
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.map(fn {ch, x} -> {{y, x}, ch} end)
  end
end
