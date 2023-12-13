defmodule Mirror.Image do
  @moduledoc """
  Image structure and functions for `Mirror`.
  """

  defstruct y: 0, x: 0, rows: [], cols: []

  require Logger

  @doc ~S"""
  Find the reflection in an image.

  ## Parameters

  - `image` - the `Image`

  Returns the reflection as a tuple:

  - `type` - the reflection type (`:horiz` or `:vert`)
  - `loc` - the reflection location (column or row, integer)
  """
  def reflection(image), do: find_reflection(image, 1, 0)

  @doc ~S"""
  Find the reflection in a smudged image.

  ## Parameters

  - `image` - the smudged `Image`

  Returns the reflection as a tuple:

  - `type` - the reflection type (`:horiz` or `:vert`)
  - `loc` - the reflection location (column or row, integer)
  """
  def smudged_reflection(image), do: find_reflection(image, 1, 1)

  defp find_reflection(image, offset, smudges) do
    Logger.debug("image #{image.y},#{image.x} offset=#{offset} smudges=#{smudges}")
    reflection =
      cond do
        (offset > image.y) && (offset > image.x) ->
          dump(image)
          raise "reflection not found, image #{image.y},#{image.x} offset=#{offset} smudges=#{smudges}"
        reflects?(image.y - offset, 0, image.rows, smudges) ->
          {:horiz, div(image.y - offset, 2)}
        reflects?(image.y - offset, offset, image.rows, smudges) ->
          {:horiz, div(image.y - offset, 2) + offset}
        reflects?(image.x - offset, 0, image.cols, smudges) ->
          {:vert,  div(image.x - offset, 2)}
        reflects?(image.x - offset, offset, image.cols, smudges) ->
          {:vert,  div(image.x - offset, 2) + offset}
        true ->
          find_reflection(image, offset + 2, smudges)
      end
    Logger.debug("found reflection #{inspect(reflection)}")
    reflection
  end

  defp reflects?(n, _, _, _) when n <= 0, do: false
  defp reflects?(n, offset, lines, smudges) do
    half = div(n, 2)
    l_range = (half - 1 + offset)..(0 + offset)
    r_range = (half - 0 + offset)..(n - 1 + offset)
    Logger.debug("n=#{n} offset=#{offset} lines=#{Enum.count(lines)} smudges=#{smudges} ranges #{inspect(l_range)} #{inspect(r_range)}")
    {matches, smudges_left} =
      [l_range, r_range]
      |> Enum.zip()
      |> Enum.reduce({true, smudges}, fn {l, r}, {matches, s} ->
        cond do
          !matches ->
            {matches, s}
          Enum.at(lines, l) == Enum.at(lines, r) ->
            {matches, s}
          (s > 0) && smudgy_match?(Enum.at(lines, l), Enum.at(lines, r)) ->
            {matches, s - 1}
          true ->
            {false, s}
        end
      end)
    matches && (smudges_left == 0)
  end

  defp smudgy_match?(l, r) do
    diff =
      [String.to_charlist(l), String.to_charlist(r)]
      |> Enum.zip()
      |> Enum.count(fn {a, b} -> a != b end)
    if diff == 1 do
      Logger.debug("[l=#{l}] <=> [r=#{r}] differ by 1")
    end
    diff == 1
  end

  def dump(image) do
    IO.puts("Y=#{image.y} X=#{image.x} rows:")
    image.rows
    |> Enum.each(fn line -> IO.puts(line) end)
    IO.puts("X=#{image.x} Y=#{image.y} cols:")
    image.cols
    |> Enum.each(fn line -> IO.puts(line) end)
  end
end
