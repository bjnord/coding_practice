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
      nodes: walk_junctions(grid, [{grid.meta.start, :east}], %{}, %{}),
      meta: %{
        start: {grid.meta.start, :east},
        end: grid.meta.end,
      },
    }
  end

  ###
  # terminology:
  # - a "corridor" square has only 1-2 passable neighbor squares
  #   (and if 2, they are in a line, not a corner)
  # - a "junction" square (`junct`) has 2-4 passable neighbor squares
  #   (NB the start and end squares are treated as junctions)
  # - a "node" is a **junction plus a facing direction**
  #   (NB the end square has a fixed facing direction; there's only one)
  ###

  defp walk_junctions(_grid, [], nodes, _seen), do: nodes
  defp walk_junctions(_grid, [{_pos, _dir} | _rem_q_juncts], _nodes, _seen) do
    %{}
  end
end
