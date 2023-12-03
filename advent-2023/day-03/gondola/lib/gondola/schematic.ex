defmodule Gondola.Schematic do
  @moduledoc """
  Schematic structure and functions for `Gondola`.
  """

  defstruct parts: [], symbols: []

  @doc """
  Find parts that are adjacent to a symbol.

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
end
