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
  Find paths through the cave system.

  ## Examples
      iex> graph = Cave.Graph.parse_input_string("start-a\nB-start\na-end\nB-end\n")
      iex> Cave.Graph.paths(graph)
      ["start,a,end", "start,B,end"]
  """
  def paths(graph), do: paths(graph, [], {:small, "start"})
  defp paths(_graph, path, {:end, _name}) do
    [
      ["end" | path]
      |> Enum.reverse()
      |> Enum.join(",")
    ]
  end
  defp paths(graph, path, {_kind, name}) do
    graph[name]
    |> Enum.reject(fn {next_kind, next_name} ->
      # puzzle rules say small caves may only be visited once
      next_kind == :small && Enum.find(path, fn n -> n == next_name end)
    end)
    |> Enum.flat_map(fn next_cave -> paths(graph, [name | path], next_cave) end)
    |> Enum.reject(fn r -> r == [] end)
  end
end
