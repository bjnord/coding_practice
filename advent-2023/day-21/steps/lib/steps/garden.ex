defmodule Steps.Garden do
  @moduledoc """
  Garden structure and functions for `Steps`.
  """

  defstruct start: {}, size: %{y: 0, x: 0}, tiles: %{}

  require Logger
  alias Steps.Garden

  @doc ~S"""
  Form a `Garden` from a list of rock tiles.

  ## Parameters

  - `tile_list` - a list of `{{y, x}, ch}` tiles

  Returns a `Garden`.
  """
  def from_tiles(tile_list) do
    tiles = Enum.into(tile_list, %{})
    {dim_y, dim_x} = dimensions(tiles)
    start_pos =
      Enum.find(tile_list, fn {_pos, ch} -> ch == ?S end)
      |> elem(0)
    %Garden{
      start: start_pos,
      size: %{y: dim_y, x: dim_x},
      tiles: Map.delete(tiles, start_pos),
    }
  end

  defp dimensions(tiles) do
    positions = Map.keys(tiles)
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end

  @doc ~S"""
  Find the number of garden plots reachable in **exactly** `n` steps.

  ## Parameters

  - `garden` - the `Garden`
  - `n` - the number steps to take (integer)

  Returns the number of reachable garden plots (integer).
  """
  def reachable(garden, n) do
    take_steps(garden, [{garden.start, n}], %{})
    |> Enum.count(fn {_k, v} -> v == :reachable end)
  end

  # Breadth-First Search (BFS)
  defp take_steps(_garden, [], seen), do: seen
  defp take_steps(garden, queue, seen) do
    {new_queue, new_seen} =
      queue
      |> Enum.reduce({[], seen}, fn {pos, n}, {acc_q, acc_s} ->
        {step_q, step_seen} = take_step(garden, pos, n, acc_s)
        {acc_q ++ step_q, step_seen}
      end)
    take_steps(garden, new_queue, new_seen)
  end

  defp take_step(_garden, _pos, -1, seen), do: {[], seen}
  defp take_step(garden, pos, n, seen) do
    if Map.get(seen, pos, :unvisited) == :unvisited do
      new_seen = Map.put(seen, pos, reachable_state(n))
      new_queue = neighbors_of(garden, pos)
                  |> Enum.map(fn pos -> {pos, n - 1} end)
      {new_queue, new_seen}
    else
      {[], seen}
    end
  end

  defp reachable_state(n) do
    if rem(n, 2) == 1, do: :unreachable, else: :reachable
  end

  defp neighbors_of(garden, {y, x}) do
    [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    |> Enum.map(fn {dy, dx} -> {y + dy, x + dx} end)
    |> Enum.reject(fn {y1, x1} ->
      out_of_bounds?(y1, garden.size.y) ||
        out_of_bounds?(x1, garden.size.x) ||
        (Map.get(garden.tiles, {y1, x1}, ?.) == ?#)
    end)
  end

  defp out_of_bounds?(n, _max) when (n < 0), do: true
  defp out_of_bounds?(n, max) when (n >= max), do: true
  defp out_of_bounds?(_n, _max), do: false

  def dump(garden, seen \\ %{}) do
    IO.puts("-- #{garden.size.y} x #{garden.size.x} -- start #{inspect(garden.start)} --")
    for y <- 0..(garden.size.y - 1), do: dump_row(garden, y, seen)
    IO.puts("---------------------------")
  end

  defp dump_row(garden, y, seen) do
    line =
      0..(garden.size.x - 1)
      |> Enum.reduce([], fn x, line ->
        [tile_at(garden, y, x, seen) | line]
      end)
      |> Enum.reverse()
      |> List.to_string()
    IO.puts(line)
  end

  defp tile_at(garden, y, x, seen) do
    cond do
      Map.get(seen, {y, x}, :unvisited) == :reachable ->
        ?O
      {y, x} == garden.start ->
        ?S
      true ->
        Map.get(garden.tiles, {y, x}, ?.)
    end
  end
end
