defmodule Probe.Parser do
  @moduledoc """
  Parsing for `Probe`.
  """

  @doc ~S"""
  Parse input as a block string.

  Returns `{{min_x, max_x}, {min_y, max_y}}`.

  ## Examples
      iex> Probe.Parser.parse("target area: x=20..30, y=-10..-5\n")
      {{20, 30}, {-10, -5}}
  """
  def parse(input) do
    Regex.run(~r/^target\s+area:\s+x=(-?\d+)\.\.(-?\d+),\s+y=(-?\d+)\.\.(-?\d+)/, input)
    |> (fn [_, x1, x2, y1, y2] ->
      {
        {String.to_integer(x1), String.to_integer(x2)},
        {String.to_integer(y1), String.to_integer(y2)},
      }
    end).()
  end
end
