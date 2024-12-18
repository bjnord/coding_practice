defmodule Dodge.Graph do
  @moduledoc """
  Parsing for `Dodge`.
  """

  alias History.Grid
  alias History.PriorityQueue
  alias Dodge.Graph

  defstruct grid: nil, cost: %{}, pqueue: nil, visited: nil

  @doc ~S"""
  Construct a new `Dodge.Graph` from `grid`.
  """
  def new(grid) do
    pqueue = PriorityQueue.new()
             |> PriorityQueue.put(grid.meta.start, 0)
    %Graph{
      grid: grid,
      cost: %{grid.meta.start => 0},
      pqueue: pqueue,
      visited: MapSet.new(),
    }
  end

  @doc ~S"""
  Find lowest-cost path from start square to end square.
  """
  def lowest_cost(graph) do
    costs(graph)
    |> Map.get(graph.grid.meta.end)
  end

  ###
  # Dijkstra shortest-path algorithm
  # - at [brilliant.org](https://brilliant.org/wiki/dijkstras-short-path-finder/)
  # - at [freecodecamp.org](https://www.freecodecamp.org/news/dijkstras-shortest-path-algorithm-visual-introduction/)
  ###

  def costs(graph) do
    ###
    # Pop the highest-priority node (lowest cost), that has not already
    # been visited, from the priority queue. In the first run, the start
    # square will be chosen (because the queue was initialized with only
    # that in it). In the next run, the next node with the lowest cost
    # is chosen.
    {graph, cur} = pop_next_unvisited_node(graph)
    ###
    # 1. Mark the chosen node as having been visited
    # 2. Update the `cost` (total path cost) values of the adjacent nodes of
    #    the current node
    graph =
      mark_visited(graph, cur)
      |> neighbors(cur)
      |> Enum.reduce(graph, fn (neighbor, graph) ->
        update_cost_of(graph, cur, neighbor)
      end)
    ###
    # When `pqueue` is empty, the lowest-cost path has been found; return
    # all node path costs to the caller. Otherwise, continue processing
    # the queue recursively (using tail recursion).
    if queue_empty?(graph) do
      graph.cost
    else
      costs(graph)
    end
  end

  defp queue_empty?(graph) do
    PriorityQueue.empty?(graph.pqueue)
  end

  # Pop the highest-priority node `next` (lowest cost), that has not
  # already been visited, from `pqueue`.
  defp pop_next_unvisited_node(graph) do
    {pqueue, next} = PriorityQueue.pop(graph.pqueue)
    graph = %Graph{graph | pqueue: pqueue}
    if visited?(graph, next) do
      pop_next_unvisited_node(graph)
    else
      {graph, next}
    end
  end

  defp mark_visited(graph, node) do
    %Graph{graph | visited: MapSet.put(graph.visited, node)}
  end

  defp visited?(graph, node) do
    MapSet.member?(graph.visited, node)
  end

  # Return a list of nodes adjacent to the `{y, x}` node.
  defp neighbors(graph, pos) do
    graph.grid
    |> Grid.cardinals_of(pos)
    |> Enum.reject(fn npos ->
      Grid.get(graph.grid, npos) == ?#
    end)
  end

  # Update the `cost` (total path cost) values of the node `neighbor`
  # which is adjacent to the `cur` node:
  # 1. `cost_at()` returns the cost of **entering** the given `neighbor`
  # 2. `new_cost` is a new calculation of the total path cost from the
  #    origin to `neighbor`, ending with the `cost_at()` from `cur` to
  #    `neighbor` we're now examining
  # 3. if the new total path cost to `neighbor` is lower than the previous
  #    one, we've found a shorter route to it:
  #    - update `cost` with the new total path cost to `neighbor`
  #    - add or update `neighbor` in the priority queue to have a new
  #      (higher) priority
  # 3. otherwise, don't update anything; the existing cost/priority is
  #    as good or better than the new path would be
  defp update_cost_of(graph, cur, neighbor) do
    cur_cost = Map.get(graph.cost, cur)
    neighbor_cost = Map.get(graph.cost, neighbor)
    new_cost = cur_cost + cost_at(graph, neighbor)
    if new_cost < neighbor_cost do
      graph = put_or_update_node(graph, neighbor, neighbor_cost, new_cost)
      %Graph{graph | cost: Map.put(graph.cost, neighbor, new_cost)}
    else
      graph
    end
  end

  defp cost_at(_graph, _neighbor), do: 1

  # Add or update `node` in `pqueue`. (`PriorityQueue` requires this
  # formulation due to the data structure it's using.) When completed,
  # `node` will be in `pqueue` with priority based on `new_cost`.
  defp put_or_update_node(graph, node, old_cost, new_cost) do
    new_pri = priority(node, new_cost)
    pqueue =
      if old_cost == nil do
        PriorityQueue.put(graph.pqueue, node, new_pri)
      else
        old_pri = priority(node, old_cost)
        PriorityQueue.update(graph.pqueue, node, old_pri, new_pri)
      end
    %Graph{graph | pqueue: pqueue}
  end

  # `PriorityQueue` requires unique priority values, so we salt
  # cost with the node position.
  defp priority({y, x}, cost) when y < 512 and x < 512 do
    cost * 512 * 512 + y * 512 + x
  end
end
