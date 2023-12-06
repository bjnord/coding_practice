defmodule Garden.Gmap do
  @moduledoc """
  Gmap structure and functions for `Garden`.
  """

  defstruct from: nil, to: nil, maps: []

  @doc """
  Transform range, by applying a range map.

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

  @doc """
  Transform value, by applying a range map.

  ## Parameters

  - `value`: the integer value
  - `gmap`: the `Gmap` to apply

  Returns the transformed integer value.
  """
  def transform(value, gmap) do
    map =
      gmap.maps
      |> Enum.find(fn map -> matching_map?(value, map) end)
    if map do
      value - map.from + map.to
    else
      value
    end
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
  Find the location of a seed, by applying successive maps.

  ## Parameters

  - `seed`: the integer seed number
  - `gmaps`: a map of the `Gmap`s to apply

  Returns the integer location value.
  """
  def location(seed, gmaps), do: location(seed, gmaps[:seed], gmaps)
  def location(value, nil, _gmaps), do: value
  def location(value, gmap, gmaps) do
    transform(value, gmap)
    |> location(gmaps[gmap.to], gmaps)
  end
end
