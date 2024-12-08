defmodule History.Math do
  @moduledoc """
  Math functions for `History`.
  """

  @doc """
  Compute the Manhattan distance between two positions.
  """
  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
  def manhattan({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
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
