defmodule Lagoon.Parser do
  @moduledoc """
  Parsing for `Lagoon`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of dig instructions (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of dig instructions (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a dig instruction.

  Returns a tuple with the following elements:
  - `dir`: the dig direction (`:up`, `:down`, `:left`, or `:right`)
  - `dist`: the dig distance (integer)
  - `color`: the paint color (integer RGB)

  ## Examples
      iex> parse_line("R 6 (#70c710)\n")
      {:right, 6, 0x70c710}
      iex> parse_line("L 10 (#4aacb2)\n")
      {:left, 10, 0x4aacb2}
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(" ")
    |> then(fn [dir, dist, color] ->
      rgb = String.slice(color, 2..(String.length(color) - 2))
      {
        parse_dir(dir),
        String.to_integer(dist),
        String.to_integer(rgb, 16),
      }
    end)
  end

  defp parse_dir("U"), do: :up
  defp parse_dir("D"), do: :down
  defp parse_dir("L"), do: :left
  defp parse_dir("R"), do: :right
end
