defmodule Segment.Parser do
  @moduledoc """
  Parsing for `Segment`.
  """

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `{signal_patterns, output_values}` tuples, where each is a list of strings.
  """
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @doc false
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(" | ")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn ss -> Enum.map(ss, &String.to_charlist/1) end)
    |> Enum.map(fn ss -> Enum.map(ss, &Enum.sort/1) end)
    |> List.to_tuple()
  end
end
