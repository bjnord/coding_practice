defmodule Reactor.Cuboid do
  @moduledoc """
  Cuboid math for `Reactor`.

  Conventions ("right-hand rule"):
  - +x right, -x left
  - +y up,    -y down
  - +z front, -z back
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
end
