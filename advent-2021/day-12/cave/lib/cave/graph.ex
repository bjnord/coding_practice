defmodule Cave.Graph do
  @moduledoc """
  Parsing for `Cave`.
  """

  @doc ~S"""
  Parse input as a block string.

  ## Examples
      iex> Cave.Graph.parse_input_string("start-a\nB-start\na-end\nB-end\n")
      %{"start" => [{:small, "a"}, {:big, "B"}],
        "a" => [{:small, "start"}, {:end, "end"}],
        "B" => [{:small, "start"}, {:end, "end"}],
        "end" => [{:small, "a"}, {:big, "B"}]}
  """
  # TODO OPTIMIZE Elixir 1.13 has `Map.map/2` which would allow us to
  # insert to head of list here, and then reverse all lists at the end
  def parse_input_string(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, fn ({a, b}, graph) ->
      # need to add each pair in both directions:
      graph
      |> Map.update(a, [categorize(b)], fn v -> v ++ [categorize(b)] end)
      |> Map.update(b, [categorize(a)], fn v -> v ++ [categorize(a)] end)
    end)
  end
  defp parse_line(line) do
    line
    |> String.trim_trailing
    |> String.split("-")
    |> List.to_tuple()
  end
  defp categorize(name) do
    cond do
      name == "end" -> {:end, name}
      String.match?(name, ~r/^\p{Lu}/u) -> {:big, name}
      true -> {:small, name}
    end
  end

  @doc ~S"""
  Find paths through the cave system in which small caves may be visited
  at most once.

  ## Examples
      iex> graph = Cave.Graph.parse_input_string("start-a\nB-start\na-end\nB-end\n")
      iex> Cave.Graph.paths(graph)
      ["start,a,end", "start,B,end"]
  """
  def paths(graph), do: paths(graph, false, [], {:small, "start"})
  defp paths(_graph, _two_visit, path, {:end, _name}) do
    [
      ["end" | path]
      |> Enum.reverse()
      |> Enum.join(",")
    ]
  end
  defp paths(graph, two_visit, path, {kind, name}) do
    ###
    # If the current cave is a small cave already on the path, this becomes
    # the second visit to it; clear `two_visit` so it can't happen again
    # further along.
    two_visit =
      cond do
        kind != :small -> two_visit
        Enum.find(path, fn n -> n == name end) -> false
        true -> two_visit
      end
    ###
    # Now continue the paths recursively, throwing away those that hit a
    # dead end.
    graph[name]
    |> Enum.reject(fn {next_kind, next_name} ->
      cond do
        # the start cave can never be revisited (regardless of `two_visit`)
        next_name == "start" -> true
        # puzzle rules say small caves may only be visited once, but if
        # `two_visit==true`, none have yet been visited twice, and we won't
        # reject the next step (allowing it to become the sole second visit)
        next_kind == :small && !two_visit -> Enum.find(path, fn n -> n == next_name end)
        true -> false
      end
    end)
    |> Enum.flat_map(fn next_cave -> paths(graph, two_visit, [name | path], next_cave) end)
    |> Enum.reject(fn r -> r == [] end)
  end

  @doc ~S"""
  Find paths through the cave system in which:
  1. The start and end caves are visited exactly once
  1. A **single** small cave may be visited at most twice
  1. All other small caves may be visited at most once

  ## Examples
      iex> graph = Cave.Graph.parse_input_string("start-a\nB-start\na-B\na-end\nB-end\n")
      iex> Cave.Graph.paths_twice(graph)
      [
        "start,a,B,a,B,end", "start,a,B,a,end", "start,a,B,end", "start,a,end",
        "start,B,a,B,a,B,end", "start,B,a,B,a,end", "start,B,a,B,end", "start,B,a,end", "start,B,end",
      ]
  """
  def paths_twice(graph), do: paths(graph, true, [], {:small, "start"})
end
