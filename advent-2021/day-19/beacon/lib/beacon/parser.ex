defmodule Beacon.Parser do
  @moduledoc """
  Parsing for `Beacon`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_scanner/1)
    |> Enum.into(%{})
  end

  defp parse_scanner(input) do
    [header | lines] = String.split(input, "\n", trim: true)
    ["---", "scanner", ns, "---"] = String.split(header)
    coords =
      lines
      |> Enum.map(fn line ->
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    {String.to_integer(ns), coords}
  end
end
