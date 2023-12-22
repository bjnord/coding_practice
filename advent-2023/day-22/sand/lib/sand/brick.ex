defmodule Sand.Brick do
  @moduledoc """
  Brick functions for `Sand`.
  """

  defstruct from: %{x: 0, y: 0, z: 0}, to: %{x: 0, y: 0, z: 0}

  @doc ~S"""
  Calculate new brick positions after they fall as far as they can.

  ## Parameters

  Returns a list of `Brick`s.
  """
  def drop(bricks) do
    bricks
    |> Enum.sort(&sorter/2)
    |> drop([])
  end

  # sort on highest coord values (`to`), with Z coord most significant
  defp sorter(a, b) do
    (a.to.z < b.to.z) ||
      ((a.to.z == b.to.z) && (a.to.x < b.to.x)) ||
      ((a.to.z == b.to.z) && (a.to.x == b.to.x) && (a.to.y <= b.to.y))
  end

  defp drop([], settled_bricks), do: Enum.reverse(settled_bricks)
  defp drop([brick | rem_bricks], settled_bricks) do
    int_z =
      settled_bricks
      |> Enum.filter(fn sb -> would_intersect?(sb, brick) end)
      |> Enum.map(fn sb -> sb.to.z end)
    new_z = if int_z == [], do: 1, else: Enum.max(int_z) + 1
    settled_brick = drop_to(brick, new_z)
    drop(rem_bricks, [settled_brick | settled_bricks])
  end

  defp would_intersect?(a, b) do
    dropped_b =
      if b.from.z > a.to.z do
        drop_to(b, a.to.z)
      else
        b
      end
    intersects?(a, dropped_b)
  end

  @doc ~S"""
  Update brick position by dropping it to the specified Z coordinate.

  ## Examples
      iex> g = %Sand.Brick{from: %{x: 1, y: 1, z: 8}, to: %{x: 1, y: 1, z: 9}}
      iex> drop_to(g, 5)
      %Sand.Brick{from: %{x: 1, y: 1, z: 5}, to: %{x: 1, y: 1, z: 6}}
  """
  def drop_to(brick, z) do
    if brick.from.z > brick.to.z do
      raise "drop_to: swapped Z-coord #{brick.from.z}-#{brick.to.z}"
    end
    if z > brick.from.z do
      raise "drop_to: rising Z #{brick.from.z} -> #{z}"
    end
    dz = brick.from.z - z
    %Sand.Brick{
      from: %{brick.from | z: brick.from.z - dz},
      to:   %{brick.to   | z: brick.to.z   - dz},
    }
  end

  @doc ~S"""
  Determine if two bricks intersect.

  ## Examples
      iex> b = %Sand.Brick{from: %{x: 0, y: 0, z: 2}, to: %{x: 2, y: 0, z: 2}}
      iex> c = %Sand.Brick{from: %{x: 0, y: 2, z: 2}, to: %{x: 2, y: 2, z: 2}}
      iex> intersects?(b, c)
      false
      iex> c = %Sand.Brick{from: %{x: 0, y: 2, z: 2}, to: %{x: 2, y: 2, z: 2}}
      iex> d = %Sand.Brick{from: %{x: 0, y: 0, z: 2}, to: %{x: 0, y: 2, z: 2}}
      iex> intersects?(c, d)
      true
  """
  def intersects?(a, b) do
    [:x, :y, :z]
    |> Enum.all?(fn c -> intersects?(a.from[c], a.to[c], b.from[c], b.to[c]) end)
  end

  defp intersects?(from_a, to_a, from_b, to_b) do
    cond do
      from_a > to_a ->
        raise "swapped A #{from_a}-#{to_a}"
      from_b > to_b ->
        raise "swapped B #{from_b}-#{to_b}"
      (from_a < from_b) && (to_a < from_b) ->
        false
      (from_b < from_a) && (to_b < from_a) ->
        false
      true ->
        true
    end
  end
end
