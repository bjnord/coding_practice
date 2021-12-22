defmodule Reactor.Cuboid do
  @moduledoc """
  Cuboid math for `Reactor`.

  A "cuboid" is made up of unit cubes from position `{x0, y0, z0}`
  to `{x1, y1, z1}`. The cuboid can be a point, line, plane, or cube
  (depending on its dimensions).

  Conventions ("right-hand rule"):
  - `+x right, -x left`
  - `+y up,    -y down`
  - `+z front, -z back`
  """

  @doc ~S"""
  Is the second given cuboid wholly contained by the first?
  """
  def contains?({{x0, y0, z0}, {x1, y1, z1}}, {{i0, j0, k0}, {i1, j1, k1}}) do
    assert_valid({{x0, y0, z0}, {x1, y1, z1}})
    assert_valid({{i0, j0, k0}, {i1, j1, k1}})
    cond do
      i0 < x0 or i1 > x1 -> false
      j0 < y0 or j1 > y1 -> false
      k0 < z0 or k1 > z1 -> false
      true               -> true
    end
  end

  @doc ~S"""
  Do the given two cuboids intersect?
  """
  def intersects?({{x0, y0, z0}, {x1, y1, z1}}, {{i0, j0, k0}, {i1, j1, k1}}) do
    assert_valid({{x0, y0, z0}, {x1, y1, z1}})
    assert_valid({{i0, j0, k0}, {i1, j1, k1}})
    cond do
      i1 < x0 or i0 > x1 -> false
      j1 < y0 or j0 > y1 -> false
      k1 < z0 or k0 > z1 -> false
      true               -> true
    end
  end

  @doc false
  def assert_valid({{x0, y0, z0}, {x1, y1, z1}}) do
    cond do
      x1 < x0 -> raise ArgumentError, "X coordinates swapped"
      y1 < y0 -> raise ArgumentError, "Y coordinates swapped"
      z1 < z0 -> raise ArgumentError, "Z coordinates swapped"
      true    -> true
    end
  end

  @doc ~S"""
  Shave off up to 6 new cuboids from the second given cuboid, defined by
  the volume **outside of** the first given cuboid (_i.e._ the area of
  non-intersection).

  If the two given cuboids don't intersect, or if the first cuboid wholly
  contains the second, this ends up returning an empty list.
  """
  def shave({{x0, y0, z0}, {x1, y1, z1}}, {{i0, j0, k0}, {i1, j1, k1}}) do
    #IO.inspect({{{x0, y0, z0}, {x1, y1, z1}}, {{i0, j0, k0}, {i1, j1, k1}}}, label: "shaving")
    ###
    # shave right (+X)
    {max_x, shavings} = if i1 > x1 and i0 <= x1 do
      {x1, [ {{x1+1, j0, k0}, {i1, j1, k1}} ]}
    else
      {1_000_000, []}
    end
    ###
    # shave left (-X)
    {min_x, shavings} = if i0 < x0 and i1 >= x0 do
      {x0, [ {{i0, j0, k0}, {x0-1, j1, k1}} | shavings]}
    else
      {-1_000_000, shavings}
    end
    ###
    # shave top (+Y)
    {max_y, shavings} = if j1 > y1 and j0 <= y1 do
      {y1, [ {{max(i0, min_x), y1+1, k0}, {min(i1, max_x), j1, k1}} | shavings]}
    else
      {1_000_000, shavings}
    end
    ###
    # shave bottom (-Y)
    {min_y, shavings} = if j0 < y0 and j1 >= y0 do
      {y0, [ {{max(i0, min_x), j0, k0}, {min(i1, max_x), y0-1, k1}} | shavings]}
    else
      {-1_000_000, shavings}
    end
    ###
    # shave front (+Z)
    shavings = if k1 > z1 and k0 <= z1 do
      [ {{max(i0, min_x), max(j0, min_y), z1+1}, {min(i1, max_x), min(j1, max_y), k1}} | shavings]
    else
      shavings
    end
    ###
    # shave back (-Z)
    shavings = if k0 < z0 and k1 >= z0 do
      [ {{max(i0, min_x), max(j0, min_y), k0}, {min(i1, max_x), min(j1, max_y), z0-1}} | shavings]
    else
      shavings
    end
  end

  @doc ~S"""
  Return count of the "on" cubes found in the given list of `cuboids`.
  """
  def count_on(cuboids) do
    cuboids
    |> Enum.map(fn {{x0, y0, z0}, {x1, y1, z1}} ->
      (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1)
    end)
    |> Enum.sum()
  end
end
