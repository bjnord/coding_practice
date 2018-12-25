defmodule Nanobot do
  @moduledoc """
  Documentation for Nanobot.
  """

  @doc """
  Determine if two nanobots intersect.
  """
  def intersect?({pos1, r1}, {pos2, r2}) do
    manhattan(pos1, pos2) <= (r1 + r2)
  end

  def intersect?(pos1, {pos2, r2}) do
    manhattan(pos1, pos2) <= r2
  end

  @doc """
  Determine intersection ranges between two nanobots.

  Returns nil if they don't overlap ranges in all 3 dimensions.
  """
  def intersection_ranges({{x1, y1, z1}, r1}, {{x2, y2, z2}, r2}) do
    x_range = i_range(x1, r1, x2, r2)
    y_range = i_range(y1, r1, y2, r2)
    z_range = i_range(z1, r1, z2, r2)
    if x_range && y_range && z_range do
      {x_range, y_range, z_range}
    else
      # bot1 and bot2 **ranges** don't overlap (though they may intersect)
      nil
    end
  end

  def intersection_ranges({x1_range, y1_range, z1_range}, {x2_range, y2_range, z2_range}) do
    x_range = r_range(x1_range, x2_range)
    y_range = r_range(y1_range, y2_range)
    z_range = r_range(z1_range, z2_range)
    if x_range && y_range && z_range do
      {x_range, y_range, z_range}
    else
      # bot1 and bot2 **ranges** don't overlap (though they may intersect)
      nil
    end
  end

  defp i_range(a_center, a_radius, b_center, b_radius) do
    {a_min, a_max} = {a_center-a_radius, a_center+a_radius}
    {b_min, b_max} = {b_center-b_radius, b_center+b_radius}
    r_range(a_min..a_max, b_min..b_max)
  end

  defp r_range(a_min..a_max, b_min..b_max) do
    cond do
      (a_max < b_min) || (a_min > b_max) ->
        nil  # ranges don't overlap
      true ->
        max(a_min, b_min)..min(a_max, b_max)
    end
  end

  @doc """
  Determine intersection ranges between one nanobot and the full list of nanobots.
  """
  def intersection_ranges_of(bots, compare_bot) do
    Enum.reduce(bots, {0, []}, fn (bot, {n_int, ints}) ->
      ranges = intersection_ranges(bot, compare_bot)
      if ranges do
        {n_int+1, [{bot, ranges} | ints]}
      else
        {n_int, ints}
      end
    end)
  end

  @doc """
  Determine the range common to a list of intersection ranges.
  """
  def reduced_ranges(intersection_ranges) do
    [{_initial_bot, initial_range} | ranges] = intersection_ranges
    ranges
    |> Enum.reduce(initial_range, fn ({_bot, range}, reduced_ranges) ->
      if range do
        new_reduced_ranges = intersection_ranges(range, reduced_ranges)
        if new_reduced_ranges do
          new_reduced_ranges
        else
          reduced_ranges
        end
      else
        reduced_ranges
      end
    end)
  end

  @doc """
  Determine the point closest to the centers of a list of nanobots.
  """
  def center_of_bots(intersection_ranges) do
    {count, x_sum, y_sum, z_sum} =
      intersection_ranges
      |> Enum.reduce({0, 0, 0, 0}, fn ({bot, _range}, {count, x_sum, y_sum, z_sum}) ->
        x = elem(elem(bot, 0), 0)
        y = elem(elem(bot, 0), 1)
        z = elem(elem(bot, 0), 2)
        {count + 1, x_sum + x, y_sum + y, z_sum + z}
      end)
    {div(x_sum, count), div(y_sum, count), div(z_sum, count)}
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
