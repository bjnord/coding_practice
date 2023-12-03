defmodule Gondola.Schematic do
  @moduledoc """
  Schematic structure and functions for `Gondola`.
  """

  defstruct parts: [], symbols: []

  @doc """
  Find parts that are adjacent to any symbol.

  Returns list of parts _e.g._ `%{number: 12, y: 0, x1: 3, x2: 4}`.
  """
  def adjacent_parts(schematic) do
    schematic.parts
    |> Enum.filter(fn part ->
      schematic.symbols
      |> Enum.find(fn symbol ->
        (symbol.y >= (part.y - 1)) && (symbol.y <= (part.y + 1)) &&
          (symbol.x >= (part.x1 - 1)) && (symbol.x <= (part.x2 + 1))
      end)
    end)
  end

  @doc """
  Find gear ratios (product of exactly 2 part numbers adjacent to `*` symbol).

  Returns list of (integer) gear ratios.
  """
  def gear_ratios(schematic) do
    schematic.symbols
    |> Enum.filter(fn symbol -> symbol.symbol == "*" end)
    |> Enum.map(fn symbol ->
      adj_parts =
        schematic.parts
        |> Enum.filter(fn part ->
          (symbol.y >= (part.y - 1)) && (symbol.y <= (part.y + 1)) &&
            (symbol.x >= (part.x1 - 1)) && (symbol.x <= (part.x2 + 1))
        end)
      if length(adj_parts) == 2 do
        Enum.at(adj_parts, 0).number * Enum.at(adj_parts, 1).number
      else
        nil
      end
    end)
    |> Enum.reject(fn ratio -> ratio == nil end)
  end
end
