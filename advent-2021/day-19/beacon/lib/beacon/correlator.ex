defmodule Beacon.Correlator do
  @moduledoc """
  Correlation for `Beacon`.
  """

  alias Beacon.Transformer, as: Transformer

  # NB any variable with "position" in name is assumed **absolute**
  #    anything relative will have "rel_" in the name

  @doc ~S"""
  Correlate a list of (absolute) positions with a list of relative positions,
  to find a matching transform and 3D offset.

  Returns `{t, {x_off, y_off, z_off}, count}`.
  """
  def correlate(positions, rel_positions) do
    ###
    # Do combinations (A x (R x T)) to find the all offsets between
    # - absolute positions A[]
    # - relative positions R[] transformed by all transforms T[]
    offsets =
      rel_positions
      |> Enum.flat_map(fn rel_pos ->
        rel_pos
        |> Transformer.transforms()
        |> Enum.flat_map(fn {t, rel_rot_pos} ->
          positions
          |> Enum.map(fn pos ->
            {t, Transformer.position_difference(pos, rel_rot_pos)}
          end)
        end)
      end)
    ###
    # Count how often each (T, offset) was found
    offset_counts =
      offsets
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    ###
    # Return the highest-occurring (T, offset)
    offset_counts
    |> Enum.map(fn {k, v} -> {k, v} end)
    |> Enum.sort_by(fn {_k, v} -> -v end)
    |> Enum.map(&(elem(&1, 0)))
    |> (fn keys -> List.first(keys) end).()
    |> (fn k -> Tuple.insert_at(k, 2, offset_counts[k]) end).()
  end
end
