defmodule Cave.Graph do
  @moduledoc """
  Parsing for `Cave`.
  """

  @doc ~S"""
  Parse input as a block string.

  ## Examples
      iex> Cave.Graph.parse_input_string("start-a\nb-start\na-end\nb-end\n")
      %{"start" => ["a", "b"], "a" => ["start", "end"], "b" => ["start", "end"], "end" => ["a", "b"]}
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
      |> Map.update(a, [b], fn v -> v ++ [b] end)
      |> Map.update(b, [a], fn v -> v ++ [a] end)
    end)
  end
  defp parse_line(line) do
    line
    |> String.trim_trailing
    |> String.split("-")
    |> List.to_tuple()
  end
end
