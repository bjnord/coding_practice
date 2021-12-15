defmodule Chiton.Parser do
  @moduledoc """
  Parsing for `Chiton`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse_input_string(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> List.to_tuple()
  end

  defp parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
    |> List.to_tuple()
  end
end
