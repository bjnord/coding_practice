defmodule Pipe.Maze do
  @moduledoc """
  Maze structure and functions for `Pipe`.
  """

  defstruct start: {}, tiles: %{}

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
    start =
      Enum.find(tile_list, fn {_pos, ch} -> ch == ?S end)
      |> elem(0)
    pipe = start_pipe(tiles, start)
    %Maze{start: start, tiles: %{tiles | start => pipe}}
  end

  # TODO should write unit tests for this
  defp start_pipe(tiles, start) do
    north = connects?(tiles, start, -1,  0, [?F, ?|, ?7])
    south = connects?(tiles, start,  1,  0, [?L, ?|, ?J])
    east  = connects?(tiles, start,  0,  1, [?7, ?-, ?J])
    west  = connects?(tiles, start,  0, -1, [?F, ?-, ?L])
    cond do
      north && south && east ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      south && east && west ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      east && west && north ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      west && north && south ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
      north && south -> ?|
      north && east  -> ?L
      north && west  -> ?J
      south && east  -> ?F
      south && west  -> ?7
      east && west   -> ?-
      true ->
        raise "invalid connect N=#{north} S=#{south} E=#{east} W=#{west}"
    end
  end

  # TODO should write unit tests for this
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
    start_dir = :east  # FIXME only works for certain inputs
    loop_len =
      Stream.cycle([true])
      |> Enum.reduce_while({0, start_dir, maze.start}, fn _, {step, dir, pos} ->
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
end
