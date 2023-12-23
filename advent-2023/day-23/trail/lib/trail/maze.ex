defmodule Trail.Maze do
  @moduledoc """
  Maze structure and functions for `Trail`.
  """

  defstruct start: {}, finish: {}, size: %{y: 0, x: 0}, tiles: %{}

  require Logger
  alias Trail.Maze

  @doc ~S"""
  Form a `Maze` from a list of tiles.

  ## Parameters

  - `tile_list` - a list of `{{y, x}, ch}` tiles

  Returns a `Maze`.
  """
  def from_tiles(tile_list) do
    tiles = Enum.into(tile_list, %{})
    {dim_y, dim_x} = dimensions(tile_list)
    start_pos = entrance_pos(tile_list, 0)
    finish_pos = entrance_pos(tile_list, dim_y - 1)
    %Maze{
      start: start_pos,
      finish: finish_pos,
      size: %{y: dim_y, x: dim_x},
      tiles: tiles,
    }
  end

  defp dimensions(tile_list) do
    positions = Enum.map(tile_list, &(elem(&1, 0)))
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end

  defp entrance_pos(tile_list, row) do
    Enum.find(tile_list, fn {{y, _x}, ch} ->
      (ch == ?.) && (y == row)
    end)
    |> elem(0)
  end

  @doc ~S"""
  Find the lengths of the possible paths through a `Maze`.

  ## Parameters

  - `maze`: the `Maze`

  Returns a list of path lengths (integers).
  """
  def path_lengths(maze) do
    walk(maze)
    |> path_lengths(maze.start, 0)
    |> List.flatten()
    |> Enum.sort(fn a, b -> a >= b end)
  end

  defp path_lengths(_graph, nil, length), do: length + 1
  defp path_lengths(graph, from_pos, length) do
    Map.get(graph, from_pos, [{0, nil}])
    |> Enum.map(fn {seg_length, to_pos} ->
      path_lengths(graph, to_pos, length + seg_length)
    end)
  end

  @doc ~S"""
  Build a path graph from a `Maze`, accounting for icy slopes.

  This version builds a Directed Acyclic Graph (DAG) by following slopes in
  a one-way direction.

  ## Parameters

  - `maze`: the `Maze`

  Returns a map describing the path graph, with:
  - key: `{y0, x0}` starting position
  - value: `{length, {y1, x1}}` length and ending position
  """
  def walk(maze) do
    {start_y, start_x} = maze.start
    walk(maze, %{}, [{{start_y + 1, start_x}, maze.start}])
  end

  defp walk(_maze, paths, []), do: paths
  defp walk(maze, paths, [{next_pos, from_pos} | queue]) do
    {length, to_pos, next_queue} =
      path(maze, true, next_pos, from_pos)
      |> tap(fn path -> Logger.debug("walk path from_pos #{inspect(from_pos)}: #{inspect(path)}") end)
    new_paths =
      Map.update(paths, from_pos, [{length, to_pos}], fn acc ->
        [{length, to_pos} | acc]
      end)
    new_queue =
      next_queue
      |> Enum.reduce(queue, fn {nq_next_pos, nq_from_pos}, acc ->
        if Map.get(new_paths, nq_from_pos, nil) do
          acc  # path already walked
        else
          [{nq_next_pos, nq_from_pos} | acc]
        end
      end)
    Logger.debug("walk new_paths #{inspect(Map.keys(new_paths))}")
    Logger.debug("walk new_queue #{inspect(new_queue)}")
    walk(maze, new_paths, new_queue)
  end

  @doc ~S"""
  Build a path graph from a `Maze`, ignoring icy slopes.

  This version builds a graph that can contain cycles. It maps every segment
  in both directions.

  ## Parameters

  - `maze`: the `Maze`

  Returns a map describing the path graph, with:
  - key: `{y0, x0}` starting position
  - value: `{length, {y1, x1}}` length and ending position
  """
  def walk_all(maze) do
    {start_y, start_x} = maze.start
    walk_all(maze, %{}, [{{start_y + 1, start_x}, maze.start}])
  end

  defp walk_all(_maze, paths, []), do: paths
  defp walk_all(maze, paths, [{next_pos, from_pos} | queue]) do
    {length, to_pos, next_queue} =
      path(maze, false, next_pos, from_pos)
      |> tap(fn path -> Logger.debug("walk_all path from_pos #{inspect(from_pos)}: #{inspect(path)}") end)
    new_paths =
      if walk_all_walked?(paths, from_pos, to_pos) do
        Logger.debug("walk_all new_paths NOT adding #{inspect(from_pos)} <-> #{inspect(to_pos)}")
        paths
      else
        Logger.debug("walk_all new_paths adding #{inspect(from_pos)} <-> #{inspect(to_pos)}")
        paths
        |> Map.update(from_pos, [{length, to_pos}], fn acc ->
          [{length, to_pos} | acc]
        end)
        |> Map.update(to_pos, [{length, from_pos}], fn acc ->
          [{length, from_pos} | acc]
        end)
      end
    new_queue =
      next_queue
      |> Enum.reduce(queue, fn {nq_next_pos, nq_from_pos}, acc ->
        if walk_all_walked?(paths, from_pos, to_pos) do
          acc  # path already walked
        else
          [{nq_next_pos, nq_from_pos} | acc]
        end
      end)
    Logger.debug("walk_all new_paths #{inspect(Map.keys(new_paths))}")
    Logger.debug("walk_all new_queue #{inspect(new_queue)}")
    walk_all(maze, new_paths, new_queue)
  end

  def walk_all_walked?(paths, from_pos, to_pos) do
    Map.get(paths, from_pos, [])
    |> Enum.any?(fn {_l, tp} -> tp == to_pos end)
  end

  defp path(maze, slopes, next_pos, from_pos) do
    Stream.cycle([true])
    |> Enum.reduce_while({1, next_pos, from_pos}, fn _, {length, pos, prev_pos} ->
      # FIXME find a more elegant way to do all this:
      neighbors = neighbors_of(maze, slopes, pos, prev_pos)
      if fork?(maze, slopes, prev_pos, neighbors) do
        Logger.debug("fork prev_pos #{inspect(prev_pos)} neighbors #{inspect(neighbors)}")
        next_queue = neighbors
                     |> Enum.map(fn npos -> {npos, pos} end)
        {:halt, {length, pos, next_queue}}
      else
        if neighbors == [] do
          {:halt, {length, pos, []}}
        else
          [next_pos] = neighbors
          if next_pos == maze.finish do
            {:halt, {length, next_pos, []}}
          else
            {:cont, {length + 1, next_pos, pos}}
          end
        end
      end
    end)
  end

  defp neighbors_of(maze, slopes, {y, x}, prev_pos) do
    [:north, :east, :south, :west]
    |> Enum.map(fn dir -> {delta_pos({y, x}, delta(dir)), dir} end)
    |> Enum.reject(fn {{ny, nx}, dir} ->
      out_of_bounds?(ny, maze.size.y) ||
        out_of_bounds?(nx, maze.size.x) ||
        impassable?(maze, slopes, {ny, nx}, dir, prev_pos)
    end)
    |> Enum.map(&(elem(&1, 0)))
  end

  defp delta(:north), do: {-1, 0}
  defp delta(:east), do: {0, 1}
  defp delta(:south), do: {1, 0}
  defp delta(:west), do: {0, -1}

  defp delta_pos({y, x}, {dy, dx}), do: {y + dy, x + dx}

  defp out_of_bounds?(n, _max) when (n < 0), do: true
  defp out_of_bounds?(n, max) when (n >= max), do: true
  defp out_of_bounds?(_n, _max), do: false

  defp fork?(maze, slopes, prev_pos, neighbors) do
    cond do
      slopes && slope?(maze, prev_pos) && slopes_out?(maze, neighbors) ->
        true
      !slopes && Enum.count(neighbors) > 1 ->
        true
      true ->
        false
    end
  end

  defp slope?(maze, pos) do
    case maze.tiles[pos] do
      # TODO is there a multivalue syntax?
      ?v -> true
      ?> -> true
      _  -> false
    end
  end

  defp slopes_out?(maze, positions) do
    positions
    |> Enum.any?(fn pos -> slope?(maze, pos) end)
  end

  defp impassable?(maze, slopes, pos, dir, prev_pos) do
    tile = maze.tiles[pos]
    cond do
      tile == ?# ->
        true
      slopes && (tile == ?v) && (dir == :north) ->
        true
      slopes && (tile == ?>) && (dir == :west) ->
        true
      pos == prev_pos ->
        true
      true ->
        false
    end
  end
end
