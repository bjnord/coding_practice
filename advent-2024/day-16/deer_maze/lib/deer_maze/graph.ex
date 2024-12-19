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
      meta: grid.meta,
    }
  end

  # terminology:
  # - a "corridor" square has only 1-2 passable neighbor squares
  # - a "junction" square (`junct`) has 3-4 passable neighbor squares
  #   (NB the start and end squares are treated as junctions)
  # - a "node" is a **junction plus a facing direction**

  defp walk_junctions(_grid, [], nodes, seen), do: nodes
  defp walk_junctions(grid, [{pos, dir} | rem_q_juncts], nodes, seen) do
    {nodes, q_juncts, seen} =
      initial_unwalked_squares(grid, pos, seen)
      |> Enum.reduce({nodes, [], seen}, fn {npos, ndir}, {nodes, q_juncts, seen} ->
        {next_junct_cost, seen} = junct_and_cost_from(grid, {pos, dir}, {npos, ndir}, seen)
        walk_junction_accumulate(nodes, {pos, dir}, next_junct_cost, q_juncts, seen)
      end)
      |> dbg()
    # TODO walk_junctions(grid, rem_q_juncts ++ q_juncts, nodes, seen)
  end

  # returns `{next_pos, next_dir}` for the neighbor squares
  # - which are the routes out of the junction at `pos`
  # - which have not yet been walked
  defp initial_unwalked_squares(grid, pos, seen) do
    passable_neighbors(grid, pos)
    |> Enum.reject(&(Map.get(seen, &1) == true))
    |> Enum.map(&({&1, dir_of(pos, &1)}))
  end

  defp passable_neighbors(grid, pos) do
    grid
    |> Grid.cardinals_of(pos)
    |> Enum.reject(fn pos -> Grid.get(grid, pos) == ?# end)
  end

  defp walk_junction_accumulate(nodes, _this_junct, nil, q_juncts, seen) do
    {nodes, q_juncts, seen}
  end
  defp walk_junction_accumulate(nodes, this_junct, next_junct_cost, q_juncts, seen) do
    {
      add_next_junct(nodes, this_junct, next_junct_cost),
      add_to_queue(nodes, q_juncts, next_junct_cost),
      seen,
    }
  end

  defp add_to_queue(nodes, q_juncts, next_junct_cost) do
    # only add to walk queue if it hasn't been added to graph yet
    if Map.get(nodes, elem(next_junct_cost, 0)) do
      q_juncts
    else
      [elem(next_junct_cost, 0) | q_juncts]
    end
  end

  defp add_next_junct(nodes, this_junct, next_junct_cost) do
    Map.update(nodes, this_junct, [next_junct_cost], &[next_junct_cost | &1])
  end

  # need to turn before walking: creates a new node, same position but
  # different facing direction
  defp junct_and_cost_from(grid, {pos, dir}, {npos, ndir}, seen) when dir != ndir do
    {{{pos, ndir}, 1000}, seen}
  end

  # walk straight ahead down corridor
  defp junct_and_cost_from(grid, {pos, dir}, {npos, ndir}, seen) when dir == ndir do
    # TODO walk_corridor(..., {npos, ndir})
    {{{:ipos, :idir}, :cost}, seen}  # TODO updated `seen` from `walk_corridor()`
  end

  defp dir_of({y, x}, {ny, nx}) do
    dir_of({ny - y, nx - x})
  end
  defp dir_of({-1, 0}), do: :north
  defp dir_of({0, 1}), do: :east
  defp dir_of({1, 0}), do: :south
  defp dir_of({0, -1}), do: :west
end
