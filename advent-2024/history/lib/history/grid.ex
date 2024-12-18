defmodule History.Grid do
  @moduledoc """
  Grid structure and functions for `History`.
  """

  defstruct size: %{y: 0, x: 0}, squares: %{}, meta: %{}

  @type t :: %__MODULE__{
    size: %{y: integer(), x: integer()},
    squares: %{{integer(), integer()} => any()},
    meta: %{atom() => any()},
  }

  alias History.Grid

  @doc ~S"""
  Form a `Grid` from a list of squares.

  ## Parameters

  - `square_list` - a list of `{{y, x}, value}` squares

  Returns a `Grid`.
  """
  def from_squares(square_list, size \\ nil) do
    squares = Enum.into(square_list, %{})
    {dim_y, dim_x} = dimensions(square_list, size)
    %Grid{
      size: %{y: dim_y, x: dim_x},
      squares: squares,
      meta: %{},
    }
  end

  def create(dim_y, dim_x) do
    %Grid{
      size: %{y: dim_y, x: dim_x},
      squares: %{},
      meta: %{},
    }
  end

  defp dimensions(square_list, nil) do
    positions = Enum.map(square_list, &(elem(&1, 0)))
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end
  defp dimensions(_square_list, size), do: size

  def in_bounds?(grid, {y, x}) do
    !out_of_bounds?(y, grid.size.y) && !out_of_bounds?(x, grid.size.x)
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

  def set_meta(grid, sym, value) do
    %{grid | meta: Map.put(grid.meta, sym, value)}
  end

  # `Map`-like functions
  def keys(grid), do: Map.keys(grid.squares)
  def values(grid), do: Map.values(grid.squares)
  def get(grid, pos, default \\ nil), do: Map.get(grid.squares, pos, default)
  def get_and_update(grid, pos, fun) do
    %{grid | squares: elem(Map.get_and_update(grid.squares, pos, fun), 1)}
  end
  def put(grid, pos, value) do
    %{grid | squares: Map.put(grid.squares, pos, value)}
  end
  def delete(grid, pos) do
    %{grid | squares: Map.delete(grid.squares, pos)}
  end
end
