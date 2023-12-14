defmodule Dish.Platform do
  @moduledoc """
  Platform structure and functions for `Dish`.
  """

  defstruct rocks: %{}, tilt: :flat

  @doc ~S"""
  Tilt a `Platform` in the specified direction.

  ## Parameters

  - `platform` - the `Platform`
  - `dir` - the tilt direction (`:flat`, `:north`, `:south`, `:east`, or `:west`)

  Returns an updated `Platform`.
  """
  def tilt(platform, _dir) do
    platform  # TODO
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
    |> Enum.reduce(0, fn {{y, x}, type}, load ->
      load + rock_load(type, y, x)
    end)
  end

  def rock_load(type, y, _x) when type == :O do
    10 - y
  end
  def rock_load(type, _y, _x), do: 0
end
