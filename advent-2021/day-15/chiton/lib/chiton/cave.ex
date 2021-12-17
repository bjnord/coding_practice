defmodule Chiton.Cave do
  @moduledoc """
  Parsing for `Chiton`.
  """

  alias Submarine.PriorityQueue, as: PriorityQueue

  defstruct dimx: 0, dimy: 0, risks: {}, dist: %{}, unvisited: [], pqueue: nil, visited: nil

  @doc ~S"""
  Construct a new `Cave` from `input`.

  ## Examples
      iex> Chiton.Cave.new("01\n23\n")
      %Chiton.Cave{dimx: 2, dimy: 2, risks: {{0, 1}, {2, 3}},
        dist: %{{0, 0} => 0},
        unvisited: [{0, 0}, {1, 0}, {0, 1}, {1, 1}],
        pqueue: {1, {0, {0, 0}, nil, nil}},
        visited: %MapSet{}}
  """
  def new(input) do
    risks= parse(input)
    [dimx] = row_widths(risks)
    dimy = tuple_size(risks)
    pqueue = PriorityQueue.new()
             |> PriorityQueue.put({0, 0}, 0)
    %Chiton.Cave{
      dimx: dimx,
      dimy: dimy,
      risks: risks,
      dist: %{{0, 0} => 0},
      unvisited: all_nodes(dimx, dimy),
      pqueue: pqueue,
      visited: MapSet.new(),
    }
  end
  defp row_widths(risks) do
    for row <- Tuple.to_list(risks),
      uniq: true,
      do: tuple_size(row)
  end
  defp all_nodes(dimx, dimy) do
    for y <- 0..dimy-1,
      x <- 0..dimx-1,
      do: {x, y}
  end

  @doc false
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> List.to_tuple()
  end
  defp parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(fn d -> d - ?0 end)
    |> List.to_tuple()
  end

  @doc ~S"""
  Find lowest-risk path from origin `{0, 0}` to lowest-right node in `Cave`.

  ## Examples
      iex> Chiton.Cave.new("01\n23\n") |> Chiton.Cave.min_total_risk()
      4
  """
  def min_total_risk(cave, _verbose \\ false) do
    distances(cave)
    |> Map.get({cave.dimx-1, cave.dimy-1})
  end
  def timed_min_total_risk(cave, verbose \\ false) do
    if verbose do
      pid = spawn(Chiton.Cave, :min_total_risk, [cave, verbose])
      {:ok, _} = :eprof.start()
      :eprof.start_profiling([pid])
      :timer.sleep(15000)  # 15s
      :eprof.stop_profiling()
      :eprof.analyze()
      :eprof.stop()
      nil
    else
      tc = :timer.tc(Chiton.Cave, :min_total_risk, [cave, verbose])
      IO.puts("min_total_risk() took #{elem(tc, 0)}µs")
      elem(tc, 1)
    end
  end

  ###
  # Dijkstra shortest-path algorithm
  # - at [brilliant.org](https://brilliant.org/wiki/dijkstras-short-path-finder/)
  # - at [freecodecamp.org](https://www.freecodecamp.org/news/dijkstras-shortest-path-algorithm-visual-introduction/)
  ###

  @doc false
  def distances(cave) do
    [cur | tail] = sort_unvisited_by_dist(cave)
    {cave, cur_} = pop_next_unvisited_node(cave)
    if cur != cur_ do
      IO.inspect({cur, cur_}, label: "pop_next_node() mismatch")
      raise "pop_next_node() mismatch"
    end
    cave = mark_visited(cave, cur)
    updated_cave =
      neighbors(cave, cur)
      |> Enum.reduce(cave, fn (neighbor, cave) ->
        update_dist_of(cave, cur, neighbor)
      end)
    if tail != [] do
      distances(%Chiton.Cave{updated_cave | unvisited: tail})
    else
      updated_cave.dist
    end
  end

  defp pop_next_unvisited_node(cave) do
    if PriorityQueue.empty?(cave.pqueue) do
      {cave, nil}
    else
      {pqueue, next} = PriorityQueue.pop(cave.pqueue)
      cave = %Chiton.Cave{cave | pqueue: pqueue}
      if visited?(cave, next) do
        pop_next_unvisited_node(cave)
      else
        {cave, next}
      end
    end
  end

  defp mark_visited(cave, node) do
    %Chiton.Cave{cave | visited: MapSet.put(cave.visited, node)}
  end

  defp visited?(cave, node) do
    MapSet.member?(cave.visited, node)
  end

  defp sort_unvisited_by_dist(cave) do
    # NB: this works because in Elixir `nil` is huge
    cave.unvisited
    |> Enum.sort_by(fn {x, y} ->
      dist = Map.get(cave.dist, {x, y})
      pos = y * 256 + x
      {dist, pos}
    end)
  end

  defp neighbors(cave, {x, y}) do
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}]
    |> Enum.reject(&(x_out_of_bounds(&1, cave.dimx)))
    |> Enum.reject(&(y_out_of_bounds(&1, cave.dimy)))
  end
  defp x_out_of_bounds({x, _y}, dimx), do: x < 0 || x >= dimx
  defp y_out_of_bounds({_x, y}, dimy), do: y < 0 || y >= dimy

  defp update_dist_of(cave, cur, neighbor) do
    cur_dist = Map.get(cave.dist, cur)
    neighbor_dist = Map.get(cave.dist, neighbor)
    new_dist = cur_dist + risk_at(cave.risks, neighbor)
    if new_dist < neighbor_dist do
      cave = put_or_update_node(cave, neighbor, neighbor_dist, new_dist)
      %Chiton.Cave{cave | dist: Map.put(cave.dist, neighbor, new_dist)}
    else
      cave
    end
  end

  defp put_or_update_node(cave, node, old_dist, new_dist) do
    new_pri = priority(node, new_dist)
    pqueue =
      if old_dist == nil do
        PriorityQueue.put(cave.pqueue, node, new_pri)
      else
        old_pri = priority(node, old_dist)
        PriorityQueue.update(cave.pqueue, node, old_pri, new_pri)
      end
    %Chiton.Cave{cave | pqueue: pqueue}
  end

  # PriorityQueue requires unique priority values, so we salt
  # distance with the node position
  defp priority({x, y}, dist) when x < 256 and y < 256 do
    dist * 256 * 256 + y * 256 + x
  end

  defp risk_at(risks, {x, y}), do: elem(elem(risks, y), x)
end
