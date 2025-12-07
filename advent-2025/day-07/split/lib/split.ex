defmodule Split do
  @moduledoc """
  Documentation for `Split`.
  """

  import Split.Parser
  import Decor.CLI
  alias Decor.Grid

  @doc """
  Count the number of times the beam will be split (part 1 rules).
  """
  @spec count_splits(Grid.t()) :: integer()
  def count_splits(grid) do
    {start_y, start_x} = grid.meta.start
    count_splits_on_row(grid, start_y + 1, grid.size.y, [start_x], 0)
  end

  defp count_splits_on_row(_grid, y, max_y, _beams, count) when y > max_y, do: count

  defp count_splits_on_row(grid, y, max_y, beams, count) do
    # in both `splitter_map` and `new_beams_map`, key = `x` (column)
    splitter_map = splitters_on_row(grid, y)
    {n_splits, new_beams_map} =
      beams
      |> Enum.reduce({0, %{}}, fn beam, {n_splits, new_beams_map} ->
        if Map.get(splitter_map, beam) do
          {
            n_splits + 1,
            Map.put(new_beams_map, beam - 1, true) |> Map.put(beam + 1, true)
          }
        else
          {
            n_splits,
            Map.put(new_beams_map, beam, true)
          }
        end
      end)
    count_splits_on_row(grid, y + 1, max_y, Map.keys(new_beams_map), count + n_splits)
  end

  # return a Map of the splitters on row `y`
  # - key: `x` (column of splitter)
  # - value: `y` (row)
  defp splitters_on_row(grid, y) do
    Grid.keys(grid)
    |> Enum.filter(fn {ky, _kx} -> ky == y end)
    |> Enum.map(fn {ky, kx} -> {kx, ky} end)
    |> Enum.into(%{})
  end

  @doc """
  Count the number of worlds the split quantum beam will visit (part 2 rules).
  """
  @spec count_worlds(Grid.t()) :: integer()
  def count_worlds(grid) do
    Grid.keys(grid)
    |> Enum.sort(:desc)
    |> Enum.reduce(%{}, fn splitter_pos, acc ->
      Map.put(acc, splitter_pos, n_worlds_from_splitter(acc, splitter_pos, grid.size.y))
    end)
    |> n_worlds_along_path(grid.meta.start, grid.size.y)
  end

  defp n_worlds_from_splitter(worlds, {y, x}, max_y) do
    right = n_worlds_along_path(worlds, {y, x + 1}, max_y)
    left = n_worlds_along_path(worlds, {y, x - 1}, max_y)
    left + right
  end

  defp n_worlds_along_path(_worlds, {y, _x}, max_y) when y > max_y, do: 1

  defp n_worlds_along_path(worlds, {y, x}, max_y) do
    case Map.get(worlds, {y, x}) do
      nil -> n_worlds_along_path(worlds, {y + 1, x}, max_y)
      n   -> n
    end
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> count_splits()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> count_worlds()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
