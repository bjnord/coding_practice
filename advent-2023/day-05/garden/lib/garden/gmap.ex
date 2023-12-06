defmodule Garden.Gmap do
  @moduledoc """
  Garden map structure and functions.
  """

  defstruct from: nil, to: nil, maps: []

  @doc """
  Transform a range, by applying a garden map.

  ## Parameters

  - `{value, length}`: the range to transform (integer value and range length)
  - `gmap`: the `Gmap` to apply

  Returns a list of transformed ranges (`{value, length}` tuples)
  """
  def transform({value, length}, gmap) do
    Stream.cycle([true])
    |> Enum.reduce_while({value, length, []}, fn _, {acc_v, acc_len, ranges} ->
      map =
        gmap.maps
        |> Enum.find(fn map -> matching_map?(acc_v, map) end)
      {new_v, new_len} =
        if map do
          {
            acc_v - map.from + map.to,
            min(acc_len, map.from + map.length - acc_v),
          }
        else
          map =
            gmap.maps
            |> nearest_map(acc_v)
          if map do
            {
              acc_v,
              min(acc_len, map.from - acc_v),
            }
          else
            {
              acc_v,
              acc_len,
            }
          end
        end
      new_acc = {acc_v + new_len, acc_len - new_len, [{new_v, new_len} | ranges]}
      if elem(new_acc, 1) < 1 do
        {:halt, new_acc}
      else
        {:cont, new_acc}
      end
    end)
    |> elem(2)
    |> Enum.reverse()
  end

  defp matching_map?(value, map) do
    from = map.from
    to = map.from + map.length - 1
    (value >= from) && (value <= to)
  end

  defp nearest_map(maps, value) do
    maps
    |> Enum.filter(fn map -> map.from > value end)
    |> Enum.min_by(fn map -> map.from end, fn -> nil end)
  end

  @doc """
  Find the minimum location of a seed range, by applying successive garden maps.

  ## Parameters

  - `{seed, length}`: the seed range to transform (integer value and range length)
  - `gmaps`: a map of the `Gmap`s to apply

  Returns the minimum location value (integer).
  """
  def min_location({seed, length}, gmaps), do: min_location({seed, length}, :seed, gmaps)
  defp min_location({value, _length}, :location, _gmaps), do: value
  defp min_location({value, length}, gmap_type, gmaps) do
    transform({value, length}, gmaps[gmap_type])
    |> Enum.map(fn {value, length} -> min_location({value, length}, gmaps[gmap_type].to, gmaps) end)
    |> Enum.min()
  end
end
