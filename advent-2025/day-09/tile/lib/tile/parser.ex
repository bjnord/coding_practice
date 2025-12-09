defmodule Tile.Parser do
  @moduledoc """
  Parsing for `Tile`.
  """

  alias Decor.Grid

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
    |> Enum.map(&parse_line/1)
    |> Enum.map(fn pos -> {pos, ?#} end)
    |> Grid.from_squares()
  end

  @doc ~S"""
  Parse an input line containing red tile positions.

  ## Parameters

  - `line`: the `X,Y` position

  ## Returns

  the red tile position, as a `{y, x}` tuple

  ## Examples
      iex> parse_line("2,4\n")
      {4, 2}
      iex> parse_line("10,20\n")
      {20, 10}
  """
  @spec parse_line(String.t()) :: {integer(), integer()}
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(",")
    |> then(fn [x, y] ->
      {String.to_integer(y), String.to_integer(x)}
    end)
  end
end
