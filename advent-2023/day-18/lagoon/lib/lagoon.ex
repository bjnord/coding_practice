defmodule Lagoon do
  @moduledoc """
  Documentation for `Lagoon`.
  """

  import Lagoon.Parser
  import Snow.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
    if Enum.member?(opts[:parts], 3), do: part3(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    |> lagoon_size()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Process input file and dump border and lagoon maps.
  """
  def part3(input_file) do
    border_map =
      parse_input(input_file)
      |> dig_border()
    border_map
    |> dump(label: "Border Map")
    lagoon_map =
      border_map
      |> dig_lagoon()
    lagoon_map
    |> dump(label: "Lagoon Map")
  end

  @doc """
  Find lagoon border size from a list of dig instructions.

  ## Parameters

  - `instructions`: the list of dig instructions

  Returns the lagoon border size (integer).
  """
  def border_size(instructions) do
    instructions
    |> dig_border()
    |> Map.keys()
    |> Enum.count()
  end

  @doc """
  Dig lagoon border tiles from a list of dig instructions.

  ## Parameters

  - `instructions`: the list of dig instructions

  Returns a map of dug border tiles (key = `{y, x}` position tuple).
  """
  def dig_border(instructions) do
    initial_map_pos =
      {
        %{{0, 0} => ?#},
        {0, 0},
      }
    instructions
    |> Enum.reduce(initial_map_pos, fn {dir, dist, _}, {map, {y, x}} ->
      {dy, dx} = dir_offset(dir)
      1..dist
      |> Enum.reduce({map, {y, x}}, fn _, {map, {y, x}} ->
        {
          Map.put(map, {y + dy, x + dx}, ?#),
          {y + dy, x + dx}
        }
      end)
    end)
    |> elem(0)
  end

  defp dir_offset(:up), do: {-1, 0}
  defp dir_offset(:down), do: {1, 0}
  defp dir_offset(:left), do: {0, -1}
  defp dir_offset(:right), do: {0, 1}

  @doc """
  Find lagoon size from a list of dig instructions.

  ## Parameters

  - `instructions`: the list of dig instructions

  Returns the lagoon size (integer).
  """
  def lagoon_size(instructions) do
    instructions
    |> dig_border()
    |> dig_lagoon()
    |> Map.keys()
    |> Enum.count()
  end

  @doc """
  Finish digging lagoon by digging interior tiles.

  ## Parameters

  - `map`: the map of (already-dug) border tiles (key = `{y, x}` position tuple)

  Returns a map of dug tiles (key = `{y, x}` position tuple).
  """
  def dig_lagoon(map) do
    {min_y, min_x, max_y, max_x} = dimensions(map)
    # FIXME this would fail if lagoon doesn't include center tile
    {y0, x0} = {div(max_y + min_y, 2), div(max_x + min_x, 2)}
    flood_dig(map, [{y0, x0}], 1_000_000_000)
  end

  def flood_dig(map, [], _lim), do: map
  def flood_dig(map, _queue, 0), do: map
  def flood_dig(map, [{y, x} | queue], lim) do
    new_queue =
      [:right, :left, :down, :up]
      |> Enum.reduce(queue, fn dir, q_acc ->
        {dy, dx} = dir_offset(dir)
        new_pos = {y + dy, x + dx}
        if Map.get(map, {y, x}, ?.) == ?. do
          [new_pos | q_acc]
        else
          q_acc
        end
      end)
    flood_dig(Map.put(map, {y, x}, ?#), new_queue, lim - 1)
  end

  def dump(map, opts \\ []) do
    {min_y, min_x, max_y, max_x} = dimensions(map)
    if opts[:label] do
      IO.puts("-- [#{opts[:label]}] --")
    else
      IO.puts("-- #{max_y - min_y + 1}x#{max_x - min_x + 1} @ #{min_y},#{min_x} --")
    end
    for y <- min_y..max_y, do: dump_row(map, y, {min_x, max_x})
    IO.puts("")
  end

  defp dump_row(map, y, {min_x, max_x}) do
    line =
      min_x..max_x
      |> Enum.reduce([], fn x, line ->
        [tile_at(map, y, x) | line]
      end)
      |> Enum.reverse()
      |> List.to_string()
    IO.puts(line)
  end

  defp tile_at(map, y, x), do: Map.get(map, {y, x}, ?.)

  # Returns map dimensions as `{min_y, min_x, max_y, max_x}`.
  defp dimensions(map) do
    positions = Map.keys(map)
    {
      elem(Enum.min_by(positions, fn {y, _x} -> y end), 0),
      elem(Enum.min_by(positions, fn {_y, x} -> x end), 1),
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0),
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1),
    }
  end
end
