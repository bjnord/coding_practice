defmodule Dish.Parser do
  @moduledoc """
  Parsing for `Dish`.
  """

  alias Dish.Platform

  @doc ~S"""
  Parse the input file.

  Returns a `Platform`.
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a `Platform`.
  """
  def parse_input_string(input, _opts \\ []) do
    rocks =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(&parse_line/1)
      |> List.flatten()
      |> Enum.into(%{})
    {height, width} =
      Map.keys(rocks)
      |> Enum.reduce({0, 0}, fn {y, x}, {max_h, max_w} ->
        {
          max(max_h, y + 1),
          max(max_w, x + 1),
        }
      end)
    %Platform{rocks: rocks, size: {height, width}, tilt: :flat}
  end

  @doc ~S"""
  Parse an input line containing platform rock characters.

  ## Parameters

  `line` - the input line
  `y` - the y position (integer) of the input line

  Returns the rocks on the input line and their positions, as a
  list of `{{y, x}, type}` tuples.

  ## Examples
      iex> parse_line({".#OO.\n", 1})
      [{{1, 1}, :M}, {{1, 2}, :O}, {{1, 3}, :O}]
      iex> parse_line({".O.O.\n", 2})
      [{{2, 1}, :O}, {{2, 3}, :O}]
  """
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reject(fn {ch, _x} -> ch == ?. end)
    |> Enum.map(fn {ch, x} -> {{y, x}, parse_char(ch)} end)
  end

  defp parse_char(ch) when ch == ?O, do: :O
  defp parse_char(ch) when ch == ?#, do: :M
end
