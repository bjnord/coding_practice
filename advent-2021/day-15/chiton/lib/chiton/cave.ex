defmodule Chiton.Cave do
  @moduledoc """
  Parsing for `Chiton`.
  """

  defstruct dimx: 0, dimy: 0, risks: {}, dist: %{}, unvisited: []

  @doc ~S"""
  Construct a new `Cave` from `input`.

  ## Examples
      iex> Chiton.Cave.new("01\n23\n")
      %Chiton.Cave{dimx: 2, dimy: 2, risks: {{0, 1}, {2, 3}},
        dist: %{{0, 0} => 0},
        unvisited: [{0, 0}, {1, 0}, {0, 1}, {1, 1}]}
  """
  def new(input) do
    risks= parse(input)
    [dimx] = row_widths(risks)
    dimy = tuple_size(risks)
    %Chiton.Cave{
      dimx: dimx,
      dimy: dimy,
      risks: risks,
      dist: %{{0, 0} => 0},
      unvisited: all_nodes(dimx, dimy),
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

  defp sort_unvisited_by_dist(cave) do
    # NB: this works because in Elixir `nil` is huge
    cave.unvisited
    |> Enum.sort_by(&(Map.get(cave.dist, &1)))
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
      %Chiton.Cave{cave | dist: Map.put(cave.dist, neighbor, new_dist)}
    else
      cave
    end
  end
  defp risk_at(risks, {x, y}), do: elem(elem(risks, y), x)
end
