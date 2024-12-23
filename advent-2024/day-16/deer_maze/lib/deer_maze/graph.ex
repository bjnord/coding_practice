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

  ###
  # terminology:
  # - a "corridor" square has only 1-2 passable neighbor squares
  # - a "junction" square (`junct`) has 3-4 passable neighbor squares
  #   (NB the start and end squares are treated as junctions)
  # - a "node" is a **junction plus a facing direction**
  #   (NB the end square has a fixed facing direction; there's only one)
  ###

  ###
  # Junction (Graph Node) Functions
  ###

  defp walk_junctions(_grid, [], nodes, _seen), do: nodes
  defp walk_junctions(grid, [{pos, dir} | rem_q_juncts], nodes, seen) do
    #IO.puts("")
    #IO.puts("==")
    #[{pos, dir} | rem_q_juncts]
    #|> IO.inspect(label: "walk_junctions queue")
    {nodes, q_juncts, seen} =
      initial_unwalked_squares(grid, pos, seen)
      |> Enum.reduce({nodes, [], seen}, fn {npos, ndir}, {nodes, q_juncts, seen} ->
        #IO.puts("")
        {junct_and_cost, seen} = junct_and_cost_from(grid, {pos, dir}, {npos, ndir}, seen)
                                 #|> IO.inspect(label: "walk_junctions {junct_and_cost, seen}")
        {a, b, c} = walk_junction_accumulate(nodes, {pos, dir}, junct_and_cost, q_juncts, seen)
        #a
        #|> IO.inspect(label: "walk_junction_accumulate nodes")
        #b
        #|> IO.inspect(label: "walk_junction_accumulate q_juncts")
        #c
        #|> IO.inspect(label: "walk_junction_accumulate seen")
        {a, b, c}
      end)
    walk_junctions(grid, rem_q_juncts ++ q_juncts, nodes, seen)
  end

  # returns `{next_pos, next_dir}` for the neighbor squares
  # - which are the routes out of the junction at `pos`
  # - which have not yet been walked
  defp initial_unwalked_squares(grid, pos, seen) do
    passable_neighbors(grid, pos)
    |> Enum.reject(&(Map.get(seen, &1) == true))
    |> Enum.map(&({&1, dir_of(grid, pos, &1)}))
  end

  defp passable_neighbors(grid, pos) do
    grid
    |> Grid.cardinals_of(pos)
    |> Enum.reject(fn pos -> Grid.get(grid, pos) == ?# end)
  end

  defp walk_junction_accumulate(nodes, _this_junct, nil, q_juncts, seen) do
    {nodes, q_juncts, seen}
  end
  defp walk_junction_accumulate(nodes, this_junct, junct_and_cost, q_juncts, seen) do
    {
      add_next_junct(nodes, this_junct, junct_and_cost),
      add_to_queue(nodes, q_juncts, junct_and_cost),
      seen,
    }
  end

  defp add_to_queue(nodes, q_juncts, {{_pos, dir}, _cost} = junct_and_cost) do
    # only add to walk queue if
    # - it hasn't been added to graph yet (maybe)
    # - it isn't the end node
    cond do
      #Map.get(nodes, elem(junct_and_cost, 0)) ->
      #  q_juncts
      dir == :end ->
        q_juncts
      true ->
        [elem(junct_and_cost, 0) | q_juncts]
    end
  end

  defp add_next_junct(nodes, this_junct, junct_and_cost) do
    Map.update(nodes, this_junct, [junct_and_cost], &[junct_and_cost | &1])
  end

  # walk straight ahead down corridor
  defp junct_and_cost_from(grid, {pos, dir}, {npos, ndir}, seen) when (ndir == dir) or (ndir == :end) do
    walk_into_corridor(seen, grid, {pos, dir}, {npos, ndir}, 0)
  end

  # need to turn before walking: creates a new node, same position but
  # different facing direction
  defp junct_and_cost_from(_grid, {pos, dir}, {npos, ndir}, seen) when ndir != dir do
    #IO.puts("rotating ***")
    junct_with_turn({pos, dir}, {npos, ndir}, seen)
  end

  # "Don't turn around, uh-oh... (ja-ja)"
  defp junct_with_turn({_pos, :north}, {_npos, :south}, seen), do: {nil, seen}
  defp junct_with_turn({_pos, :south}, {_npos, :north}, seen), do: {nil, seen}
  defp junct_with_turn({_pos, :east}, {_npos, :west}, seen), do: {nil, seen}
  defp junct_with_turn({_pos, :west}, {_npos, :east}, seen), do: {nil, seen}
  defp junct_with_turn({pos, _dir}, {_npos, ndir}, seen) do
    #IO.puts("adding 1000 ***")
    {{{pos, ndir}, 1000}, seen}
  end

  ###
  # Corridor Walking Functions
  ###

  # returns `junct_and_cost, seen`
  # which is `{{pos, dir}, cost}, seen`
  #
  # - `pos` is square we're leaving
  # - `npos` is square we're entering
  # - `npos_neighbors` are the neighbors of the square we're **entering**
  #   - (without `pos` which we just left)
  defp walk_into_corridor(seen, grid, {pos, dir}, {npos, ndir}, cost) do
    #{{pos, dir}, {npos, ndir}, cost}
    #|> IO.inspect(label: "walk_into_corridor {this, next, cost}")
    npos_neighbors =
      passable_neighbors(grid, npos)
      |> Enum.reject(&(&1 == pos))
      #|> IO.inspect(label: "walk_into_corridor npos_neighbors")
    {nndir, nnpos} = first_neighbor_dir_pos(grid, npos, npos_neighbors)
                     #|> IO.inspect(label: "walk_into_corridor {nndir, nnpos}")
    cond do
      length(npos_neighbors) == 0 ->
        dead_end(seen, {npos, ndir})
      ndir == :end ->
        walk_into_junction(seen, grid, {npos, ndir}, cost)
      (length(npos_neighbors) == 1) && ((nndir == ndir) || (nndir == :end)) ->
        walk_into_straight_corridor(seen, grid, {npos, ndir}, {nnpos, nndir}, cost)
      (length(npos_neighbors) == 1) && (nndir != ndir) ->
        walk_into_corner_corridor(seen, grid, {npos, ndir}, {nnpos, nndir}, cost)
      length(npos_neighbors) > 1 ->
        walk_into_junction(seen, grid, {npos, ndir}, cost)
    end
  end

  defp first_neighbor_dir_pos(_grid, _npos, []), do: {nil, nil}
  defp first_neighbor_dir_pos(grid, npos, [nnpos | _]) do
    {dir_of(grid, npos, nnpos), nnpos}
  end

  defp dead_end(seen, {npos, ndir}) do
    #{npos, ndir}
    #|> IO.inspect(label: "dead end")
    {nil, seen}
  end

  # in the following functions:
  # - `npos` is square we're entering
  # - `nnpos` is square we're going after that

  defp walk_into_straight_corridor(seen, grid, {npos, ndir}, {nnpos, nndir}, cost) do
    Map.put(seen, npos, true)
    |> walk_into_corridor(grid, {npos, ndir}, {nnpos, nndir}, cost + 1)
  end

  defp walk_into_corner_corridor(seen, grid, {npos, ndir}, {nnpos, nndir}, cost) do
    Map.put(seen, npos, true)
    |> walk_into_corridor(grid, {npos, ndir}, {nnpos, nndir}, cost + 1001)
  end

  # always a straight walk in (junction and corner are never adjacent)
  defp walk_into_junction(seen, _grid, {npos, ndir}, cost) do
    #{{npos, ndir}, cost}
    #|> IO.inspect(label: "walk_into_junction {next, cost}")
    {{{npos, ndir}, cost + 1}, seen}
  end

  defp dir_of(grid, {y, x}, {ny, nx}) do
    n_end? = ({ny, nx} == grid.meta.end)
    dir_of(n_end?, {ny - y, nx - x})
  end
  defp dir_of(true, _delta), do: :end
  defp dir_of(false, {-1, 0}), do: :north
  defp dir_of(false, {0, 1}), do: :east
  defp dir_of(false, {1, 0}), do: :south
  defp dir_of(false, {0, -1}), do: :west
end
