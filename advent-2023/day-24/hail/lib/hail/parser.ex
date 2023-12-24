defmodule Hail.Parser do
  @moduledoc """
  Parsing for `Hail`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of hailstones (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of hailstones (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a hailstone position/velocity descriptor.

  Returns a hailstone.

  ## Examples
      iex> parse_line("12, 15,  8 @ -3,  2, -1\n")
      {{12, 15, 8}, {-3, 2, -1}}
      iex> parse_line(" 7, 11, 17 @  1, -2,  3\n")
      {{7, 11, 17}, {1, -2, 3}}
  """
  def parse_line(line) do
    line
    |> String.split("@")
    |> Enum.map(&parse_xyz/1)
    |> List.to_tuple()
  end

  defp parse_xyz(tokens) do
    tokens
    |> String.split(",")
    |> Enum.map(fn token ->
      token
      |> String.trim()
      |> String.to_integer()
    end)
    |> List.to_tuple()
  end
end
