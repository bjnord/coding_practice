defmodule DeerMaze.Graph do
  @moduledoc """
  Graph structure and functions for `DeerMaze`.
  """

  defstruct nodes: %{}, meta: %{}

  @type t :: %__MODULE__{
    nodes: %{{integer(), integer()} => []},
    meta: %{atom() => any()},
  }

  alias DeerMaze.Graph
  alias History.Grid

  @doc ~S"""
  Produce a cost graph from a puzzle grid

  ## Parameters

  - `grid`: the puzzle input `Grid`

  ## Returns

  a `Graph`
  """
  @spec from_grid(Grid.t()) :: Graph.t()
  def from_grid(grid) do
    %Graph{
      nodes: walk(grid, [{grid.meta.start, :east}], %{}),
      meta: grid.meta,
    }
  end

  defp walk(_grid, [], acc_nodes), do: acc_nodes
  defp walk(grid, [{pos, dir} | rem_nodes], acc_nodes) do
    acc_nodes
  end

  defp dir_of({y, x}, {ny, nx}) do
    dir_of({ny - y, nx - x})
  end
  defp dir_of({-1, 0}), do: :north
  defp dir_of({0, 1}), do: :east
  defp dir_of({1, 0}), do: :south
  defp dir_of({0, -1}), do: :west
end
