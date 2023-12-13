defmodule Mirror.Parser do
  @moduledoc """
  Parsing for `Mirror`.
  """

  alias Mirror.Image

  @doc ~S"""
  Parse the input file.

  Returns a list of `Image`s.
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Image`s.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n\n", trim: true)
    |> Stream.map(&parse_block/1)
  end

  @doc ~S"""
  Parse a list of input lines containing an image.

  Returns an `Image`.

  ## Examples
      iex> parse_block("##.#.\n.#.#.\n.#.#.\n")
      %Mirror.Image{
        y: 3,
        x: 5,
        rows: [
          "##.#.",
          ".#.#.",
          ".#.#.",
        ],
        cols: [
          "#..",
          "###",
          "...",
          "###",
          "...",
        ]
      }
  """
  def parse_block(block) do
    lines =
      block
      |> String.trim_trailing()
      |> String.split("\n")
    cols = transpose(lines)
    %Image{
      y: Enum.count(lines),
      x: Enum.count(cols),
      rows: lines,
      cols: cols,
    }
  end

  defp transpose(lines) do
    lines
    |> Enum.map(&String.to_charlist/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&List.to_string/1)
  end
end
