defmodule Nanobot do
  @moduledoc """
  Documentation for Nanobot.
  """

  @doc """
  Determine if a nanobot is in range of a 3-D search space.
  """
  def in_range_of?({{x, y, z}, r}, {x_min..x_max, y_min..y_max, z_min..z_max}) do
    if (x in x_min..x_max) && (y in y_min..y_max) && (z in z_min..z_max) do
      true
    else
      edges =
        for ex <- [x_min, x_max], ey <- [y_min, y_max], ez <- [z_min, z_max],
          do: manhattan({x, y, z}, {ex, ey, ez}) <= r
      Enum.any?(edges)
    end
  end

  @doc """
  Determine how many nanobots are in range of a 3-D search space.
  """
  def in_range_count(bots, space) do
    bots
    |> Enum.reduce(0, fn (bot, count) ->
      case in_range_of?(bot, space) do
        true -> count + 1
        false -> count
      end
    end)
  end

  @doc """
  Determine how far a 3-D search space is from the origin.
  """
  def space_distance_to_0({x_min.._x_max, y_min.._y_max, z_min.._z_max}) do
    manhattan({0, 0, 0}, {x_min, y_min, z_min})
  end

  @doc """
  Determine size of a 3-D search space.
  """
  def space_size({x_min..x_max, y_min..y_max, z_min..z_max}) do
    (x_max - x_min + 1) * (y_max - y_min + 1) * (z_max - z_min + 1)
  end

  @doc """
  Partition a 3-D search space into 2^3 spaces.

  If one or more search dimensions are points, will return fewer than 2^3.
  Once all search dimensions are points, will return one (the input point).
  """
  def space_partitions({x_min..x_max, y_min..y_max, z_min..z_max}) do
    all_parts =
      for xr <- half_ranges(x_min, x_max),
        yr <- half_ranges(y_min, y_max),
        zr <- half_ranges(z_min, z_max),
        do: {xr, yr, zr}
    Enum.uniq(all_parts)
  end

  defp half_ranges(min, max) when min == max-1 do
    [min..min, max..max]
  end

  defp half_ranges(min, max) do
    half = min + div(max - min, 2)
    [min..half, half..max]
  end

  @doc """
  Determine the 3-D search space encompassing all nanobots.
  """
  def encompassing_space(bots) do
    initial = {2_147_483_647..-2_147_483_647, 2_147_483_647..-2_147_483_647, 2_147_483_647..-2_147_483_647}
    bots
    |> Enum.reduce(initial, fn ({{x, y, z}, r}, {nx..mx, ny..my, nz..mz}) ->
      # bigger than strictly necessary, but that won't hurt
      {min(x-r, nx)..max(x+r, mx), min(y-r, ny)..max(y+r, my), min(z-r, nz)..max(z+r, mz)}
    end)
  end

  @doc """
  Compute the Manhattan distance between two 3-D points.

  "Take the sum of the absolute values of the differences of the coordinates.
  For example, if x=(a,b) and y=(c,d), the Manhattan distance between x and y is |a−c|+|b−d|."
  <https://math.stackexchange.com/a/139604>

  ## Example

  iex> Nanobot.manhattan({1, 2, 3}, {2, 3, 4})
  3
  """
  def manhattan({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end
