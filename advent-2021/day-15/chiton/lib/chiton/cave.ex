defmodule Chiton.Cave do
  @moduledoc """
  Parsing for `Chiton`.
  """

  alias Submarine.PriorityQueue, as: PriorityQueue

  defstruct dimx: 0, dimy: 0, scale: 1, risks: {}, dist: %{}, pqueue: nil, visited: nil

  @defaults [scale: 1]

  @doc ~S"""
  Construct a new `Cave` from `input`.

  ## Options
  - `scale:` makes the cave bigger by a factor of N (default 1)

  ## Examples
      iex> Chiton.Cave.new("01\n23\n")
      %Chiton.Cave{dimx: 2, dimy: 2, scale: 1, risks: {{0, 1}, {2, 3}},
        dist: %{{0, 0} => 0}, pqueue: {1, {0, {0, 0}, nil, nil}}, visited: %MapSet{},
      }
  """
  def new(input, opts \\ []) do
    risks = parse(input)
    opts = Keyword.merge(@defaults, opts)
    [dimx] = row_widths(risks)
    dimy = tuple_size(risks)
    pqueue = PriorityQueue.new()
             |> PriorityQueue.put({0, 0}, 0)
    %Chiton.Cave{
      dimx: dimx,
      dimy: dimy,
      scale: opts[:scale],
      risks: risks,
      dist: %{{0, 0} => 0},
      pqueue: pqueue,
      visited: MapSet.new(),
    }
  end
  defp row_widths(risks) do
    for row <- Tuple.to_list(risks),
      uniq: true,
      do: tuple_size(row)
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
    |> Map.get({cave.dimx * cave.scale - 1, cave.dimy * cave.scale - 1})
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
    {cave, cur} = pop_next_unvisited_node(cave)
    cave =
      mark_visited(cave, cur)
      |> neighbors(cur)
      |> Enum.reduce(cave, fn (neighbor, cave) ->
        update_dist_of(cave, cur, neighbor)
      end)
    if queue_empty?(cave) do
      cave.dist
    else
      distances(cave)
    end
  end

  defp queue_empty?(cave) do
    PriorityQueue.empty?(cave.pqueue)
  end

  defp pop_next_unvisited_node(cave) do
    if queue_empty?(cave) do
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

  defp neighbors(cave, {x, y}) do
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}]
    |> Enum.reject(&(x_out_of_bounds(&1, cave.dimx, cave.scale)))
    |> Enum.reject(&(y_out_of_bounds(&1, cave.dimy, cave.scale)))
  end
  defp x_out_of_bounds({x, _y}, dimx, scale), do: x < 0 || x >= dimx * scale
  defp y_out_of_bounds({_x, y}, dimy, scale), do: y < 0 || y >= dimy * scale

  defp update_dist_of(cave, cur, neighbor) do
    cur_dist = Map.get(cave.dist, cur)
    neighbor_dist = Map.get(cave.dist, neighbor)
    new_dist = cur_dist + risk_at(cave, neighbor)
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
  defp priority({x, y}, dist) when x < 512 and y < 512 do
    dist * 512 * 512 + y * 512 + x
  end

  @doc false
  def risk_at(cave, {x, y}) do
    # find tile position
    tx = div(x, cave.dimx)
    ty = div(y, cave.dimy)
    # find position within tile
    x = rem(x, cave.dimx)
    y = rem(y, cave.dimy)
    # get scaled risk
    cond do
      tx >= cave.scale or ty >= cave.scale ->
        raise "invalid position #{x},#{y} for #{cave.dimx}x#{cave.dimy} scale #{cave.scale}"
      tx == 0 and ty == 0 ->
        unscaled_risk_at(cave, {x, y})
      true ->
        shift = tx + ty
        # get base-tile risk value, changed from 1..9 to 0..8
        ans = unscaled_risk_at(cave, {x, y}) - 1
        # add shift (modulo 9), still 0..8
        ans = rem(ans + shift, 9)
        # return it as 1..9
        ans + 1
    end
  end
  defp unscaled_risk_at(cave, {x, y}), do: elem(elem(cave.risks, y), x)
end
