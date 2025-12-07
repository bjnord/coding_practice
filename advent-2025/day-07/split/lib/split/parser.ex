defmodule Split.Parser do
  @moduledoc """
  Parsing for `Split`.
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
    |> Enum.with_index()
    |> Enum.flat_map(&parse_line/1)
    |> Grid.from_squares()
    |> mark_start()
  end

  defp mark_start(grid) do
    Grid.keys(grid)
    |> Enum.reduce(grid, fn pos, acc ->
      if Grid.get(grid, pos) == ?S do
        Grid.delete(grid, pos)
        |> Grid.set_meta(:start, pos)
      else
        acc
      end
    end)
  end

  @doc ~S"""
  Parse an input line containing puzzle square characters.

  - "A tachyon beam enters the manifold at the location marked `S`"
  - "tachyon beams pass freely through empty space (`.`)"
  - "if a tachyon beam encounters a splitter (`^`)"

  ## Parameters

  - `line`: the puzzle input line
  - `y`: the y position of the input line

  ## Returns

  the non-empty puzzle square characters and their positions, as a list of
  `{{y, x}, ch}` tuples

  ## Examples
      iex> parse_line({"..S^.\n", 0})
      [{{0, 2}, ?S}, {{0, 3}, ?^}]
      iex> parse_line({".^..^\n", 1})
      [{{1, 1}, ?^}, {{1, 4}, ?^}]
  """
  @spec parse_line({String.t(), integer()}) :: [puzzle_square()]
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reject(fn {ch, _x} -> ch == ?. end)
    |> Enum.map(fn {ch, x} -> {{y, x}, ch} end)
  end
end
