defmodule Garden.Gmap do
  @moduledoc """
  Gmap structure and functions for `Garden`.
  """

  defstruct from: nil, to: nil, maps: []

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
