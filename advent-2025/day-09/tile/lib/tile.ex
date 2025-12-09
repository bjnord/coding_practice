defmodule Tile do
  @moduledoc """
  Documentation for `Tile`.
  """

  import Tile.Parser
  import Decor.CLI
  alias Decor.Grid

  @doc """
  Find the pair of red tiles that enclose the greatest area.
  """
  def max_area_tiles(grid) do
    grid
    |> Grid.keys()
    |> Enum.sort()
    |> tile_areas([])
    |> Enum.sort(fn a, b -> elem(a, 0) > elem(b, 0) end)
    |> Enum.map(fn {_dist, a, b} -> {a, b} end)
    |> List.first()
  end

  defp tile_areas([next_tile, rem_tile], acc) do
    dist = {tile_area(next_tile, rem_tile), next_tile, rem_tile}
    [dist | acc]
  end
  defp tile_areas([next_tile | rem_tiles], acc) do
    acc =
      rem_tiles
      |> Enum.reduce(acc, fn rem_tile, acc ->
        dist = {tile_area(next_tile, rem_tile), next_tile, rem_tile}
        [dist | acc]
      end)
    tile_areas(rem_tiles, acc)
  end

  @doc """
  Find the area enclosed by two red tile positions.
  """
  def tile_area({y1, x1}, {y2, x2}) do
    (abs(y1 - y2) + 1) * (abs(x1 - x2) + 1)
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
    |> max_area_tiles()
    |> then(fn {a, b} -> tile_area(a, b) end)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
