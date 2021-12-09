defmodule Smoke.FloorMap do
  @moduledoc """
  Floor map for `Smoke`.
  """

  @doc ~S"""
  Build a `FloorMap` from a (2D) list of `locations`.
  """
  def build_floor_map(locations) do
    locations
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {column, x} -> {{x, y}, column} end)
    end)
    |> Enum.into(%{})
  end

  @doc ~S"""
  Find low points of a `FloorMap`.

  Returns list of `{{x, y}, height}` locations.
  """
  def low_points(map) do
    Map.keys(map)
    |> Enum.filter(fn k -> Smoke.FloorMap.is_low_point?(map, k) end)
    |> Enum.map(fn k -> {k, map[k]} end)
  end
  def is_low_point?(map, {x, y}) do
    [{x, y-1}, {x+1, y}, {x, y+1}, {x-1, y}]
    |> Enum.all?(fn k ->
      !Map.has_key?(map, k) || (map[{x, y}] < map[k])
    end)
  end

  @doc ~S"""
  Calculate risk level sum from list of `locations`.
  """
  def risk_level_sum(locations) do
    locations
    |> Enum.map(fn l -> elem(l, 1) end)
    |> Enum.map(fn h -> h + 1 end)
    |> Enum.sum()
  end
end
