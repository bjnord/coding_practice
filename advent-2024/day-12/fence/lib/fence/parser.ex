defmodule Fence.Parser do
  @moduledoc """
  Parsing for `Fence`.
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
    |> set_regions()
  end

  defp set_regions(grid) do
    regions =
      find_regions(grid, hd(Grid.keys(grid)), [])
      |> Enum.reverse()
    Grid.set_meta(grid, :regions, regions)
  end

  defp find_regions(_grid, nil, regions), do: regions
  defp find_regions(grid, pos, regions) do
    region =
      find_region(grid, pos, %{})
      |> elem(0)
      |> then(fn {plant, positions} -> {plant, Enum.sort(positions)} end)
    grid = clear_region_positions(grid, region)
    next_pos = List.first(Grid.keys(grid))
    find_regions(grid, next_pos, [region | regions])
  end

  defp find_region(grid, pos, seen) do
    plant = Grid.get(grid, pos)
    grid
    |> Grid.cardinals_of(pos)
    |> Enum.reduce({[pos], Map.put(seen, pos, true)}, fn npos, {positions, seen} ->
      accumulate_positions(grid, plant, npos, positions, seen)
    end)
    |> then(fn {positions, seen} -> {{plant, positions}, seen} end)
  end

  defp accumulate_positions(grid, plant, npos, positions, seen) do
    if (Grid.get(grid, npos) == plant) && !seen[npos] do
      {{_new_plant, new_positions}, new_seen} = find_region(grid, npos, seen)
      {new_positions ++ positions, new_seen}
    else
      {positions, seen}
    end
  end

  defp clear_region_positions(grid, {_plant, positions}) do
    positions
    |> Enum.reduce(grid, fn rpos, grid ->
      Grid.delete(grid, rpos)
    end)
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
      iex> parse_line({".A..B\n", 0})
      [{{0, 1}, ?A}, {{0, 4}, ?B}]
      iex> parse_line({"..DC.\n", 1})
      [{{1, 2}, ?D}, {{1, 3}, ?C}]
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
