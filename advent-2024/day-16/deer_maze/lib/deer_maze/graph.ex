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
      nodes: recursive_walk(grid, [{grid.meta.start, :east}], %{}),
      meta: grid.meta,
    }
  end

  # TODO need to eliminate loops (DAG)
  defp recursive_walk(_grid, [], acc_nodes), do: acc_nodes
  defp recursive_walk(grid, [{pos, dir} | rem_nodes], acc_nodes) do
    new_walks = walk_from_node(grid, {pos, dir})
    unseen_walks =
      new_walks
      |> Enum.reject(fn {pos, dir, _cost} ->
        Map.has_key?(acc_nodes, {pos, dir})
      end)
      # TODO do we need to reduce multiple A->B to lowest-cost one?
    if length(unseen_walks) == 0 do
      recursive_walk(grid, rem_nodes, acc_nodes)
    else
      unseen_nodes =
        unseen_walks
        |> Enum.map(fn {pos, dir, _cost} -> {pos, dir} end)
      recursive_walk(grid, rem_nodes ++ unseen_nodes, Map.put(acc_nodes, {pos, dir}, new_walks))
    end
  end

  defp walk_from_node(grid, {pos, dir}) do
    branches(grid, {pos, dir}, %{})
    |> Enum.map(fn branch ->
      walk(grid, branch, %{pos => true}, 0)
    end)
    |> Enum.reject(&(&1 == nil))
  end

  defp walk(grid, {pos, _dir, cost}, _seen, acc_cost) when pos == grid.meta.end, do: {pos, :end, acc_cost + cost}
  defp walk(grid, {pos, dir, cost}, seen, acc_cost) do
    choices = branches(grid, {pos, dir}, seen)
    case length(choices) do
      0 ->
        nil
      1 ->
        walk(grid, hd(choices), Map.put(seen, pos, true), acc_cost + cost)
      _ ->
        {pos, dir, acc_cost + cost}
    end
  end

  defp branches(grid, {pos, dir}, seen) do
    Grid.cardinals_of(grid, pos)
    |> Enum.reject(fn npos ->
      (Grid.get(grid, npos) == ?#) || Map.get(seen, npos)
    end)
    |> Enum.map(&(branch_to_choice(pos, dir, &1)))
  end

  defp branch_to_choice(pos, dir, npos) do
    ndir = dir_of(pos, npos)
    if dir == ndir do
      {npos, dir, 1}
    else
      {npos, ndir, 1001}
    end
  end

  defp dir_of({y, x}, {ny, nx}) do
    dir_of({ny - y, nx - x})
  end
  defp dir_of({-1, 0}), do: :north
  defp dir_of({0, 1}), do: :east
  defp dir_of({1, 0}), do: :south
  defp dir_of({0, -1}), do: :west
end
