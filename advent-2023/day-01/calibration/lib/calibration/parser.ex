defmodule Calibration.Parser do
  @moduledoc """
  Parsing for `Calibration`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a calibration value.

  Returns a charlist.

  ## Examples
      iex> Calibration.Parser.parse_line("xyzzy7plugh92")
      'xyzzy7plugh92'
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
  end
end
