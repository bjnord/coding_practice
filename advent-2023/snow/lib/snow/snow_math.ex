defmodule Snow.SnowMath do
  @moduledoc """
  Math functions for `Snow`.
  """

  @doc """
  Compute the Least Common Multiple (LCM) of a list of integers.

  ## Parameters

  - `numbers`: a list of integers

  Returns the LCM (integer).
  """
  def lcm([n | numbers]) when is_integer(n) do
    numbers
    |> Enum.reduce(n, fn n, acc -> lcm(n, acc) end)
  end

  @doc """
  Compute the Least Common Multiple (LCM) of a pair of integers.

  ## Parameters

  - `a`: the first integer
  - `b`: the second integer

  Returns the LCM (integer).
  """
  def lcm(a, b) when is_integer(a) and is_integer(b) do
    div((a * b), Integer.gcd(a, b))
  end

  @doc """
  Compute the Manhattan distance between two 3D positions.
  """
  def manhattan({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end
