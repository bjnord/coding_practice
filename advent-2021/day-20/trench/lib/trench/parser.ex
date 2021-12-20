defmodule Trench.Parser do
  @moduledoc """
  Parsing for `Trench`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input) do
    [algor, pixels] = String.split(input, "\n\n")
    {parse_algor(algor), parse_image(pixels)}
  end

  @doc false
  def parse_algor(algor) do
    algor
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.map(fn {ch, i} ->
      px = if ch == ?., do: 0, else: 1
      {i, px}
    end)
    |> Enum.into(%{})
  end

  defp parse_image(pixels) do
    lines =
      pixels
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim_trailing/1)
    n_lines = Enum.count(lines)
    y_off = div(n_lines, 2)
    line_len = String.length(List.first(lines))
    x_off = div(line_len, 2)
    pixmap =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {ch, x} ->
          px = if ch == ?., do: 0, else: 1
          {{x - x_off, y - y_off}, px}
        end)
      end)
      |> Enum.into(%{})
    {max(x_off, y_off), pixmap}
  end
end
