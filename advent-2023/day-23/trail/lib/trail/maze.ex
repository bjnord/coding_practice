defmodule Trail.Maze do
  @moduledoc """
  Maze structure and functions for `Trail`.
  """

  defstruct start: {}, finish: {}, size: %{y: 0, x: 0}, tiles: %{}

  require Logger
  alias Trail.Maze

  @doc ~S"""
  Form a `Maze` from a list of tiles.

  ## Parameters

  - `tile_list` - a list of `{{y, x}, ch}` tiles

  Returns a `Maze`.
  """
  def from_tiles(tile_list) do
    tiles = Enum.into(tile_list, %{})
    {dim_y, dim_x} = dimensions(tile_list)
    start_pos = entrance_pos(tile_list, 0)
    finish_pos = entrance_pos(tile_list, dim_y - 1)
    %Maze{
      start: start_pos,
      finish: finish_pos,
      size: %{y: dim_y, x: dim_x},
      tiles: tiles,
    }
  end

  defp dimensions(tile_list) do
    positions = Enum.map(tile_list, &(elem(&1, 0)))
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end

  defp entrance_pos(tile_list, row) do
    Enum.find(tile_list, fn {{y, _x}, ch} ->
      (ch == ?.) && (y == row)
    end)
    |> elem(0)
  end
end
