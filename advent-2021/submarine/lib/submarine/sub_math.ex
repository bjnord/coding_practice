defmodule Submarine.SubMath do
  @moduledoc """
  Command-line parsing for `Submarine`.
  """

  @doc """
  Compute the Manhattan distance between two 3D positions.
  """
  def manhattan({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end
