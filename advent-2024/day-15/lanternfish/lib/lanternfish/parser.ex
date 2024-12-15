defmodule Lanternfish.Parser do
  @moduledoc """
  Parsing for `Lanternfish`.
  """

  alias History.Grid

  @type puzzle_square() :: {{integer(), integer()}, char()}

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a `Grid` and list of directions
  """
  @spec parse_input_file(String.t(), []) :: {Grid.t(), [atom()]}
  def parse_input_file(path, opts \\ []) do
    path
    |> File.read!()
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a `Grid` and list of directions
  """
  @spec parse_input_string(String.t(), []) :: {Grid.t(), [atom()]}
  def parse_input_string(input, opts \\ []) do
    [grid_s, dir_s] =
      input
      |> String.split("\n\n", trim: true)
    {
      parse_input_grid(grid_s, opts),
      parse_directions(dir_s),
    }
  end

  @doc ~S"""
  Parse an input grid.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a `Grid`
  """
  @spec parse_input_grid(String.t(), []) :: Grid.t()
  def parse_input_grid(input, opts) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(&(parse_line(&1, opts)))
    |> Grid.from_squares()
    |> mark_start()
  end

  defp mark_start(grid) do
    Grid.keys(grid)
    |> Enum.reduce(grid, fn pos, acc ->
      if Grid.get(grid, pos) == ?@ do
        Grid.delete(grid, pos)
        |> Grid.set_meta(:start, pos)
      else
        acc
      end
    end)
  end

  @doc ~S"""
  Parse an input line containing puzzle square characters.

  ## Parameters

  - `line`: the puzzle input line
  - `y`: the y position of the input line
  - `opts`: parsing options

  ## Returns

  the non-empty puzzle square characters and their positions, as a list of
  `{{y, x}, ch}` tuples

  ## Examples
      iex> parse_line({"#####\n", 0})
      [{{0, 0}, ?#}, {{0, 1}, ?#}, {{0, 2}, ?#}, {{0, 3}, ?#}, {{0, 4}, ?#}]
      iex> parse_line({"#@.O#\n", 1})
      [{{1, 0}, ?#}, {{1, 1}, ?@}, {{1, 3}, ?O}, {{1, 4}, ?#}]
      iex> parse_line({"#@.O\n", 2}, wide: true)
      [{{2, 0}, ?#}, {{2, 1}, ?#}, {{2, 2}, ?@}, {{2, 6}, ?[}, {{2, 7}, ?]}]
  """
  @spec parse_line({String.t(), integer()}, []) :: [puzzle_square()]
  def parse_line({line, y}, opts \\ []) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reject(fn {ch, _x} -> ch == ?. end)
    |> Enum.flat_map(fn {ch, x} -> parse_pos(y, x, ch, opts[:wide]) end)
  end

  defp parse_pos(y, x, ch, wide) do
    case {ch, wide} do
      {?#, true} ->
        [{{y, (x * 2)}, ?#}, {{y, (x * 2) + 1}, ?#}]
      {?O, true} ->
        [{{y, (x * 2)}, ?[}, {{y, (x * 2) + 1}, ?]}]
      {?@, true} ->
        [{{y, (x * 2)}, ?@}]
      {?#, _} ->
        [{{y, x}, ?#}]
      {?O, _} ->
        [{{y, x}, ?O}]
      {?@, _} ->
        [{{y, x}, ?@}]
    end
  end

  @doc ~S"""
  Parse an input line containing a list of directions.

  "The moves form a single giant sequence; they are broken into multiple
  lines just to make copy-pasting easier. Newlines within the move sequence
  should be ignored."

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a list of directions

  ## Examples
      iex> parse_directions("<^>^\n>v>v\n")
      [:west, :north, :east, :north, :east, :south, :east, :south]
  """
  @spec parse_directions(String.t()) :: [atom()]
  def parse_directions(line) do
    line
    |> String.to_charlist()
    |> Enum.map(&parse_direction/1)
    |> Enum.reject(&(&1 == nil))
  end

  defp parse_direction(ch) do
    case ch do
      ?^ -> :north
      ?> -> :east
      ?v -> :south
      ?< -> :west
      10 -> nil
    end
  end
end
