defmodule Dish.Platform do
  @moduledoc """
  Platform structure and functions for `Dish`.
  """

  defstruct rocks: %{}, size: {0, 0}, tilt: :flat

  alias Dish.Platform

  @doc ~S"""
  Tilt a `Platform` in the specified direction.

  ## Parameters

  - `platform` - the `Platform`
  - `dir` - the tilt direction (`:flat`, `:north`, `:south`, `:east`, or `:west`)

  Returns an updated `Platform`.
  """
  def tilt(platform, dir) when dir == :north do
    rockslide =
      columns(platform)
      |> Enum.map(fn {_col, rocks} ->
        slide_column(rocks)
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

  defp slide_column(rocks) do
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

  @doc ~S"""
  Calculate the load on a `Platform` on the specified side.

  ## Parameters

  - `platform` - the `Platform`
  - `dir` - the measurement direction (`:north`, `:south`, `:east`, or `:west`)

  Returns the load amount (integer).
  """
  def load(platform, dir) when dir == :north do
    platform.rocks
    |> Enum.reduce(0, fn rock, total_load ->
      total_load + north_rock_load(platform.size, rock)
    end)
  end

  def north_rock_load({h, _w}, {{y, _x}, type}) when type == :O, do: h - y
  def north_rock_load(_size, _rock), do: 0
end
