defmodule Pipe.Maze do
  @moduledoc """
  Maze structure and functions for `Pipe`.
  """

  defstruct start: {}, tiles: %{}

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
  def steps(_maze) do
    0  # TODO
  end
end
