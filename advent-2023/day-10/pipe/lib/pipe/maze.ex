defmodule Pipe.Maze do
  @moduledoc """
  Maze structure and functions for `Pipe`.
  """

  defstruct start: {}, start_dir: nil, tiles: %{}

  require Logger
  alias Pipe.Maze

  @doc ~S"""
  Form a `Maze` from a list of pipe tiles.

  ## Parameters

  - `tile_list` - a list of `{{y, x}, ch}` tiles

  Returns a `Maze`.
  """
  def from_tiles(tile_list) do
    tiles = Enum.into(tile_list, %{})
    start_pos =
      Enum.find(tile_list, fn {_pos, ch} -> ch == ?S end)
      |> elem(0)
    {start_tile, start_dir} = start_pipe(tiles, start_pos)
    %Maze{
      start: start_pos,
      start_dir: start_dir,
      tiles: %{tiles | start_pos => start_tile},
    }
  end

  defp start_pipe(tiles, pos) do
    north = connects?(tiles, pos, -1,  0, [?F, ?|, ?7])
    south = connects?(tiles, pos,  1,  0, [?L, ?|, ?J])
    east  = connects?(tiles, pos,  0,  1, [?7, ?-, ?J])
    west  = connects?(tiles, pos,  0, -1, [?F, ?-, ?L])
    cond do
      north && south && east ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      south && east && west ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      east && west && north ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      west && north && south ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      north && south -> {?|, :south}
      north && east  -> {?L, :north}
      north && west  -> {?J, :west}
      south && east  -> {?F, :east}
      south && west  -> {?7, :south}
      east && west   -> {?-, :west}
      true ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
    end
  end

  defp connects?(tiles, {y, x}, dy, dx, possibles) do
    pos = {y + dy, x + dx}
    Enum.any?(possibles, fn p -> tiles[pos] == p end)
  end

  @doc ~S"""
  Form a clean `Maze` by removing junk tiles.

  ## Parameters

  - `maze` - the junky `Maze`

  Returns the `Maze` with junk tiles removed.
  """
  def clean(maze) do
    walk(maze)
    |> Enum.map(fn pos -> clean_tile(maze, pos, maze.start) end)
    |> from_tiles()
  end

  defp clean_tile(_maze, pos, start) when pos == start, do: {pos, ?S}
  defp clean_tile(maze, pos, _start), do: {pos, maze.tiles[pos]}

  @doc ~S"""
  Calculate number of steps taken by following a maze.

  ## Parameters

  - `maze` - a `Maze`

  Returns the step count (integer).
  """
  def steps(maze) do
    walk(maze)
    |> Enum.count()
    |> div(2)
  end

  @doc ~S"""
  Find steps taken by following a maze.

  ## Parameters

  - `maze` - a `Maze`

  Returns the list of steps taken, as `{y, x}` tuples.
  """
  def walk(maze) do
    Stream.cycle([true])
    |> Enum.reduce_while({0, [], maze.start_dir, maze.start}, fn _, {step, steps, dir, pos} ->
      next_pos = next_pos(pos, dir)
      next_tile = maze.tiles[next_pos]
      next_dir = next_dir(next_tile, dir)
      Logger.debug("step=#{step} pos=#{inspect(pos)} tile=#{<<maze.tiles[pos]::utf8>>} dir=#{dir} next_pos=#{inspect(next_pos)} next_tile=#{<<next_tile::utf8>>} next_dir=#{next_dir}")
      if next_pos == maze.start do
        {:halt, [pos | steps]}
      else
        {:cont, {step + 1, [pos | steps], next_dir, next_pos}}
      end
    end)
    |> Enum.reverse()
  end

  # TODO should write unit tests for these
  defp next_pos({y, x}, dir) when dir == :north, do: {y-1, x}
  defp next_pos({y, x}, dir) when dir == :south, do: {y+1, x}
  defp next_pos({y, x}, dir) when dir == :east, do: {y, x+1}
  defp next_pos({y, x}, dir) when dir == :west, do: {y, x-1}

  # TODO should write unit tests for these
  defp next_dir(tile, dir) when tile == ?F and dir == :north, do: :east
  defp next_dir(tile, dir) when tile == ?| and dir == :north, do: :north
  defp next_dir(tile, dir) when tile == ?7 and dir == :north, do: :west
  defp next_dir(tile, dir) when tile == ?L and dir == :south, do: :east
  defp next_dir(tile, dir) when tile == ?| and dir == :south, do: :south
  defp next_dir(tile, dir) when tile == ?J and dir == :south, do: :west
  defp next_dir(tile, dir) when tile == ?7 and dir == :east, do: :south
  defp next_dir(tile, dir) when tile == ?- and dir == :east, do: :east
  defp next_dir(tile, dir) when tile == ?J and dir == :east, do: :north
  defp next_dir(tile, dir) when tile == ?F and dir == :west, do: :south
  defp next_dir(tile, dir) when tile == ?- and dir == :west, do: :west
  defp next_dir(tile, dir) when tile == ?L and dir == :west, do: :north

  def dump(maze) do
    {dim_y, dim_x} = dimensions(maze)
    IO.puts("-- #{dim_y} x #{dim_x} -- start #{inspect(maze.start)} --")
    for y <- 0..(dim_y-1), do: dump_row(maze, y, dim_x)
    IO.puts("---------------------------")
  end

  defp dump_row(maze, y, dim_x) do
    line =
      0..(dim_x-1)
      |> Enum.reduce([], fn x, line ->
        [tile_at(maze, y, x) | line]
      end)
      |> Enum.reverse()
      |> List.to_string()
    IO.puts(line)
  end

  defp tile_at(maze, y, x) do
    if {y, x} == maze.start do
      ?S
    else
      Map.get(maze.tiles, {y, x}, ?.)
    end
  end

  @doc ~S"""
  Return the dimensions of a `Maze`.

  ## Parameters

  - `maze` - the `Maze`

  Returns the `{y, x}` dimensions of the maze.
  """
  def dimensions(maze) do
    positions = Map.keys(maze.tiles)
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end
end
