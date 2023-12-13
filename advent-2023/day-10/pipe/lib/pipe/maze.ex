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
  Calculate steps taken by following a maze.

  ## Parameters

  - `maze` - a `Maze`

  Returns an integer step count.
  """
  def steps(maze) do
    loop_len =
      Stream.cycle([true])
      |> Enum.reduce_while({0, maze.start_dir, maze.start}, fn _, {step, dir, pos} ->
        tile = maze.tiles[pos]
        next_pos = next_pos(pos, dir)
        next_tile = maze.tiles[next_pos]
        next_dir = next_dir(next_tile, dir)
        Logger.debug("step=#{step} pos=#{inspect(pos)} tile=#{<<tile::utf8>>} dir=#{dir} next_pos=#{inspect(next_pos)} next_tile=#{<<next_tile::utf8>>} next_dir=#{next_dir}")
        if next_pos == maze.start do
          {:halt, step + 1}
        else
          {:cont, {step + 1, next_dir, next_pos}}
        end
      end)
    div(loop_len, 2)
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
