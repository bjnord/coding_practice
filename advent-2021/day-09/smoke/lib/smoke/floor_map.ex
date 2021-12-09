defmodule Smoke.FloorMap do
  @moduledoc """
  Floor map for `Smoke`.
  """

  @doc ~S"""
  Build a `FloorMap` from a (2D) list of `locations`.
  """
  def build(locations) do
    locations
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {column, x} -> {{x, y}, column} end)
    end)
    |> Enum.into(%{})
  end
end
