defmodule Dodge.Parser do
  @moduledoc """
  Parsing for `Dodge`.
  """

  alias History.Grid

  @type puzzle_square() :: {{integer(), integer()}, char()}

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path
  - `size`: the size of the grid (`{width, height}`)
  - `limit`: the number of falling bytes to consider

  ## Returns

  a `Grid`
  """
  @spec parse_input_file(String.t(), {integer(), integer()}, integer()) :: Grid.t()
  def parse_input_file(path, size, limit) do
    path
    |> File.read!()
    |> parse_input_string(size, limit)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input
  - `size`: the size of the grid (`{width, height}`)
  - `limit`: the number of falling bytes to consider

  ## Returns

  a `Grid`
  """
  @spec parse_input_string(String.t(), {integer(), integer()}, integer()) :: Grid.t()
  def parse_input_string(input, size, limit) do
    input
    |> String.split("\n", trim: true)
    |> Enum.take(limit)
    |> Enum.map(&parse_line/1)
    |> Grid.from_squares(size)
    |> mark_start_end()
  end

  defp mark_start_end(grid) do
    end_pos = {
      grid.size.y - 1,
      grid.size.x - 1,
    }
    grid
    |> Grid.set_meta(:start, {0, 0})
    |> Grid.set_meta(:end, end_pos)
  end

  @doc ~S"""
  Parse an input line containing a puzzle square coordinate.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  the puzzle square character and its position, as a `{{y, x}, ch}` tuple

  ## Examples
      iex> parse_line("1,0\n")
      {{0, 1}, ?#}
      iex> parse_line("3,1\n")
      {{1, 3}, ?#}
  """
  @spec parse_line(String.t()) :: [puzzle_square()]
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(",")
    |> then(fn [x, y] ->
      {
        {String.to_integer(y), String.to_integer(x)},
        ?#,
      }
    end)
  end
end
