defmodule Mirror.Image do
  @moduledoc """
  Image structure and functions for `Mirror`.
  """

  defstruct y: 0, x: 0, rows: [], cols: []

  @doc ~S"""
  Find the reflection.

  ## Parameters

  - `image` - the `Image`.

  Returns the reflection as a tuple:

  - `type` - the reflection type (`:horiz` or `:vert`)
  - `loc` - the reflection location (column or row, integer)
  """
  def reflection(image), do: find_reflection(image, 1)

  defp find_reflection(image, offset) do
    cond do
      (offset > image.y) && (offset > image.x) ->
        dump(image)
        raise "reflection not found Y=#{image.y} X=#{image.x} offset=#{offset}"
      reflects?(image.y - offset, 0, image.rows) ->
        {:horiz, div(image.y - offset, 2)}
      reflects?(image.y - offset, offset, image.rows) ->
        {:horiz, div(image.y - offset, 2) + offset}
      reflects?(image.x - offset, 0, image.cols) ->
        {:vert,  div(image.x - offset, 2)}
      reflects?(image.x - offset, offset, image.cols) ->
        {:vert,  div(image.x - offset, 2) + offset}
      true ->
        find_reflection(image, offset + 2)
    end
  end

  def reflects?(n, offset, lines) do
    half = div(n, 2)
    l_range = (half - 1 + offset)..(0 + offset)
    r_range = (half - 0 + offset)..(n * 2 - 1 + offset)
    [l_range, r_range]
    |> Enum.zip()
    |> Enum.all?(fn {l, r} ->
      Enum.at(lines, l) == Enum.at(lines, r)
    end)
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
