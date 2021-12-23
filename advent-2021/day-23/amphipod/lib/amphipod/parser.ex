defmodule Amphipod.Parser do
  @moduledoc """
  Parsing for `Amphipod`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map_reduce(3, &parse_line/2)
    |> elem(0)
    |> List.flatten()
  end

  defp parse_line(line, y) do
    amphipositions =
      line
      |> String.trim_trailing()
      |> String.to_charlist()
      |> parse_amphipositions(y)
    {amphipositions, y-1}
  end

  defp parse_amphipositions(chars, y) do
    chars
    |> Enum.map_reduce(0, fn (char, x) ->
      case char do
        ?A -> {{:amber, {x, y}}, x+1}
        ?B -> {{:bronze, {x, y}}, x+1}
        ?C -> {{:copper, {x, y}}, x+1}
        ?D -> {{:desert, {x, y}}, x+1}
        _  -> {nil, x+1}
      end
    end)
    |> elem(0)
    |> Enum.reject(&(&1 == nil))
  end
end
