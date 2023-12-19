defmodule Lagoon.Parser do
  @moduledoc """
  Parsing for `Lagoon`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of dig instructions (one per line).
  """
  def parse_input(input_file, opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(fn line -> parse_line(line, opts) end)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of dig instructions (one per line).
  """
  def parse_input_string(input, opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(fn line -> parse_line(line, opts) end)
  end

  @doc ~S"""
  Parse an input line containing a dig instruction.

  (This produces a different result depending on the puzzle part rules.
  See "Examples".)

  Returns a tuple with the following elements:
  - `dir`: the dig direction (`:up`, `:down`, `:left`, or `:right`)
  - `dist`: the dig distance (integer)
  - `color`: the paint color (integer RGB)

  ## Examples
      iex> parse_line("R 6 (#70c710)\n")
      {:right, 6, 0x70c710}
      iex> parse_line("D 5 (#0dc571)\n", part: 2)
      {:down, 56407, 0x0dc571}
  """
  def parse_line(line, opts \\ []) do
    [dir, dist, color] =
      line
      |> String.trim_trailing()
      |> String.split(" ")
    rgb =
      color
      |> String.slice(2..7)
      |> String.to_integer(16)
    if opts[:part] == 2 do
      {dir, dist} = parse_line_part2(color)
      {
        dir,
        dist,
        rgb,
      }
    else
      {
        parse_dir(dir),
        String.to_integer(dist),
        rgb,
      }
    end
  end

  defp parse_dir("U"), do: :up
  defp parse_dir("D"), do: :down
  defp parse_dir("L"), do: :left
  defp parse_dir("R"), do: :right

  defp parse_line_part2(color) do
    dist = String.slice(color, 2..6)
           |> String.to_integer(16)
    dir = String.slice(color, 7..7)
          |> parse_hex_dir()
    {dir, dist}
  end

  defp parse_hex_dir("0"), do: :right
  defp parse_hex_dir("1"), do: :down
  defp parse_hex_dir("2"), do: :left
  defp parse_hex_dir("3"), do: :up
end
