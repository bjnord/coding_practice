defmodule Dish.Platform do
  @moduledoc """
  Platform structure and functions for `Dish`.
  """

  defstruct rocks: %{}, size: {0, 0}, tilt: :flat

  alias Dish.Platform
  alias Snow.Cycle

  @doc ~S"""
  Simulate running a `Platform` through N spin cycles.

  N can be very large; this function will return the correct platform state,
  as if that number of spin cycles was run.

  ## Parameters

  - `platform`: the `Platform`
  - `n`: the number of spin cycles

  Returns an updated `Platform`.
  """
  def spin_cycle_n(platform, n) do
    next_f = fn p -> spin_cycle(p) end
    compare_f = fn a, b -> hash(a) == hash(b) end
    {λ, μ} = Cycle.brent(next_f, platform, compare_f)
    n_spins = rem(n - μ, λ) + μ
    if n_spins == 0 do
      platform
    else
      0..(n_spins - 1)
      |> Enum.reduce(platform, fn _, acc -> spin_cycle(acc) end)
    end
  end

  @doc ~S"""
  Run a `Platform` through one spin cycle.

  > Each **cycle** tilts the platform four times so that the rounded rocks
  > roll **north**, then **west**, then **south**, then **east**. After
  > each tilt, the rounded rocks roll as far as they can before the
  > platform tilts in the next direction. After one cycle, the platform
  > will have finished rolling the rounded rocks in those four directions
  > in that order.

  ## Parameters

  - `platform`: the `Platform`

  Returns an updated `Platform`.
  """
  def spin_cycle(platform) do
    platform
    |> tilt(:north)
    |> tilt(:west)
    |> tilt(:south)
    |> tilt(:east)
  end

  @doc ~S"""
  Tilt a `Platform` in the specified direction.

  ## Parameters

  - `platform`: the `Platform`
  - `dir`: the tilt direction (`:flat`, `:north`, `:south`, `:east`, or `:west`)

  Returns an updated `Platform`.
  """
  # TODO lots of duplicate code here
  def tilt(platform, dir) when dir == :north do
    rockslide =
      columns(platform)
      |> Enum.map(fn {_col, rocks} ->
        slide_column_north(rocks)
      end)
      |> List.flatten()
      |> Enum.into(%{})
    %Platform{rocks: rockslide, size: platform.size, tilt: dir}
  end
  def tilt(platform, dir) when dir == :west do
    rockslide =
      rows(platform)
      |> Enum.map(fn {_row, rocks} ->
        slide_row_west(rocks)
      end)
      |> List.flatten()
      |> Enum.into(%{})
    %Platform{rocks: rockslide, size: platform.size, tilt: dir}
  end
  def tilt(platform, dir) when dir == :south do
    rockslide =
      columns(platform)
      |> Enum.map(fn {_col, rocks} ->
        slide_column_south(rocks, elem(platform.size, 0))
      end)
      |> List.flatten()
      |> Enum.into(%{})
    %Platform{rocks: rockslide, size: platform.size, tilt: dir}
  end
  def tilt(platform, dir) when dir == :east do
    rockslide =
      rows(platform)
      |> Enum.map(fn {_row, rocks} ->
        slide_row_east(rocks, elem(platform.size, 1))
      end)
      |> List.flatten()
      |> Enum.into(%{})
    %Platform{rocks: rockslide, size: platform.size, tilt: dir}
  end

  defp columns(platform) do
    platform.rocks
    |> Map.keys()
    |> Enum.sort_by(fn {y, _x} -> y end)
    |> Enum.map(fn pos -> {pos, platform.rocks[pos]} end)
    |> Enum.group_by(fn {{_y, x}, _type} -> x end)
  end

  defp rows(platform) do
    platform.rocks
    |> Map.keys()
    |> Enum.sort_by(fn {_y, x} -> x end)
    |> Enum.map(fn pos -> {pos, platform.rocks[pos]} end)
    |> Enum.group_by(fn {{y, _x}, _type} -> y end)
  end

  defp slide_column_north(rocks) do
    rocks
    |> Enum.reduce({[], 0}, fn {{y, x}, type}, {acc, stop} ->
      case type do
        :M ->
          {[{{y, x}, type} | acc], y + 1}
        :O ->
          {[{{stop, x}, type} | acc], stop + 1}
        _ ->
          raise "invalid rock type #{type}"
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp slide_row_west(rocks) do
    rocks
    |> Enum.reduce({[], 0}, fn {{y, x}, type}, {acc, stop} ->
      case type do
        :M ->
          {[{{y, x}, type} | acc], x + 1}
        :O ->
          {[{{y, stop}, type} | acc], stop + 1}
        _ ->
          raise "invalid rock type #{type}"
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp slide_column_south(rocks, height) do
    rocks
    |> Enum.reverse()
    |> Enum.reduce({[], height - 1}, fn {{y, x}, type}, {acc, stop} ->
      case type do
        :M ->
          {[{{y, x}, type} | acc], y - 1}
        :O ->
          {[{{stop, x}, type} | acc], stop - 1}
        _ ->
          raise "invalid rock type #{type}"
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp slide_row_east(rocks, width) do
    rocks
    |> Enum.reverse()
    |> Enum.reduce({[], width - 1}, fn {{y, x}, type}, {acc, stop} ->
      case type do
        :M ->
          {[{{y, x}, type} | acc], x - 1}
        :O ->
          {[{{y, stop}, type} | acc], stop - 1}
        _ ->
          raise "invalid rock type #{type}"
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  @doc ~S"""
  Calculate the load on the north side of a `Platform`.

  ## Parameters

  - `platform`: the `Platform`

  Returns the load amount (integer).
  """
  def load(platform) do
    platform.rocks
    |> Enum.reduce(0, fn rock, total_load ->
      total_load + rock_load(platform.size, rock)
    end)
  end

  defp rock_load({h, _w}, {{y, _x}, type}) when type == :O, do: h - y
  defp rock_load(_size, _rock), do: 0

  @doc ~S"""
  Dump a `Platform` to `stdout`.

  ## Parameters

  - `platform`: the `Platform`
  """
  def dump(platform, opts \\ []) do
    {dim_y, dim_x} = platform.size
    IO.puts("")
    # TODO will this work if no label option passed?
    IO.puts("-- #{dim_y} x #{dim_x} -- #{opts[:label]} --")
    for y <- 0..(dim_y-1), do: dump_row(platform, y, dim_x)
    IO.puts("------------------------")
  end

  defp dump_row(platform, y, dim_x) do
    0..(dim_x-1)
    |> Enum.reduce([], fn x, line ->
      [tile_at(platform, y, x) | line]
    end)
    |> Enum.reverse()
    |> List.to_string()
    |> IO.puts()
  end

  defp tile_at(platform, y, x) do
    case Map.get(platform.rocks, {y, x}, :none) do
      :M    -> ?#
      :O    -> ?O
      :none -> ?.
      _     -> ??
    end
  end

  @doc ~S"""
  Compute hash of a `Platform`.

  This doesn't need to be a secure hash (tamper-resistant); just fast, and
  sufficiently diverse.

  ## Parameters

  - `platform`: the `Platform`
  """
  def hash(platform) do
    platform.rocks
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn pos -> "#{inspect(pos)}" end)
    |> Enum.join(" ")
    |> then(fn s -> :crypto.hash(:md5, s) end)
  end
end
