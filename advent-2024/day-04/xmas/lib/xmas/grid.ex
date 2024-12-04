defmodule Xmas.Grid do
  @moduledoc """
  Grid structure and functions for `Xmas`.
  """

  defstruct size: %{y: 0, x: 0}, squares: %{}

  @type t :: %__MODULE__{
    size: %{y: integer(), x: integer()},
    squares: %{{integer(), integer()} => any()}
  }

  alias Xmas.Grid

  @doc ~S"""
  Form a `Grid` from a list of squares.

  ## Parameters

  - `square_list` - a list of `{{y, x}, value}` squares

  Returns a `Grid`.
  """
  def from_squares(square_list) do
    squares = Enum.into(square_list, %{})
    {dim_y, dim_x} = dimensions(square_list)
    %Grid{
      size: %{y: dim_y, x: dim_x},
      squares: squares,
    }
  end

  defp dimensions(square_list) do
    positions = Enum.map(square_list, &(elem(&1, 0)))
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end

  def neighbors_of(grid, {y, x}) do
    [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    |> Enum.map(fn dxdy -> delta_pos({y, x}, dxdy) end)
    |> Enum.reject(fn {ny, nx} ->
      out_of_bounds?(ny, grid.size.y) || out_of_bounds?(nx, grid.size.x)
    end)
  end

  def cardinals_of(grid, {y, x}) do
    [:north, :east, :south, :west]
    |> Enum.map(fn dir -> delta_pos({y, x}, delta(dir)) end)
    |> Enum.reject(fn {ny, nx} ->
      out_of_bounds?(ny, grid.size.y) || out_of_bounds?(nx, grid.size.x)
    end)
  end

  defp delta(:north), do: {-1, 0}
  defp delta(:east), do: {0, 1}
  defp delta(:south), do: {1, 0}
  defp delta(:west), do: {0, -1}

  defp delta_pos({y, x}, {dy, dx}), do: {y + dy, x + dx}

  defp out_of_bounds?(n, _max) when (n < 0), do: true
  defp out_of_bounds?(n, max) when (n >= max), do: true
  defp out_of_bounds?(_n, _max), do: false

  # `Map`-like functions
  def keys(grid), do: Map.keys(grid.squares)
  def values(grid), do: Map.values(grid.squares)
  def get(grid, pos, default \\ nil), do: Map.get(grid.squares, pos, default)
  def get_and_update(grid, pos, fun) do
    %{grid | squares: elem(Map.get_and_update(grid.squares, pos, fun), 1)}
  end
end
