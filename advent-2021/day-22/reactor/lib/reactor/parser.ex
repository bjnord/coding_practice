defmodule Reactor.Parser do
  @moduledoc """
  Parsing for `Reactor`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  # on x=10..12,y=10..12,z=10..12
  defp parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split()
    |> (fn [oo_s, coords_s] -> {String.to_atom(oo_s), parse_coords(coords_s)} end).()
  end

  # x=10..12,y=10..12,z=10..12 -> {{10, 10, 10}, {12, 12, 12}}
  defp parse_coords(coords) do
    coords
    |> String.split(",")
    |> Enum.map(&parse_coord/1)
    |> Submarine.transpose()
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  # x=10..12 -> [10, 12]
  defp parse_coord(coord) do
    coord
    |> String.split(["=", ".."])
    |> List.delete_at(0)
    |> Enum.map(&String.to_integer/1)
  end
end
