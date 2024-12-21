defmodule History.Math do
  @moduledoc """
  Math functions for `History`.
  """

  @type coord_2d() :: {integer(), integer()}
  @type coord_3d() :: {integer(), integer(), integer()}

  @doc """
  Compute the Manhattan distance between two positions.

  The positions use integer coordinates.
  """
  @spec manhattan(coord_2d(), coord_2d()) :: integer()
  def manhattan({y1, x1}, {y2, x2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end
  @spec manhattan(coord_3d(), coord_3d()) :: integer()
  def manhattan({z1, y1, x1}, {z2, y2, x2}) do
    abs(z1 - z2) + abs(y1 - y2) + abs(x1 - x2)
  end

  @doc """
  Return unique pairings from a list.

  (Someday this should be generalized permutation and combination
  functions.)
  """
  def pairings([]), do: []
  def pairings([_]), do: []
  def pairings([h | t]) do
    Enum.map(t, &({h, &1})) ++ pairings(t)
  end
end
