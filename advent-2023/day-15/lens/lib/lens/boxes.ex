defmodule Lens.Boxes do
  @moduledoc """
  Box functions for `Lens`.
  """

  @doc ~S"""
  Install lenses in boxes according to initialization instructions.

  ## Parameters

  - `instructions`: a list of instruction tuples, each with:
    - `box_n`: box number (integer)
    - `op`: `:install` or `:remove`
    - `label`: the lens label (string)
    - `focal`: the lens focal length (integer; only present for `:install`)

  Returns the resulting boxes (map).
  """
  def install(instructions) do
    instructions
    |> Enum.reduce(%{}, fn inst, boxes ->
      Map.get(boxes, elem(inst, 0), [])
      |> lens_op(inst)
      |> then(fn lenses -> Map.put(boxes, elem(inst, 0), lenses) end)
    end)
  end

  defp lens_op(box, {_box_n, :install, i_label, i_focal}) do
    box
    |> Enum.reduce({[], false}, fn {label, focal}, {lenses, saw} ->
      if label == i_label do
        # replace
        {[{i_label, i_focal} | lenses], true}
      else
        {[{label, focal} | lenses], saw}
      end
    end)
    |> then(fn {lenses, saw} ->
      # add (if not replaced above)
      if saw, do: lenses, else: [{i_label, i_focal} | lenses]
    end)
    |> Enum.reverse()
  end

  defp lens_op(box, {_box_n, :remove, r_label}) do
    box
    |> Enum.reduce([], fn {label, focal}, lenses ->
      if label == r_label do
        # remove
        lenses
      else
        [{label, focal} | lenses]
      end
    end)
    |> Enum.reverse()
  end

  @doc ~S"""
  Calculate focusing power of the lenses in the boxes

  ## Parameters

  - `boxes`: the boxes (map; key is integer box ID from 0-255)

  Returns the focusing power (integer).
  """
  def power(boxes) do
    boxes
    |> Enum.flat_map(fn {box_n, lenses} ->
      lenses
      |> Enum.with_index()
      |> Enum.map(fn {lens, i} -> power(box_n, lens, i) end)
    end)
    |> Enum.sum()
  end

  defp power(box_n, {_label, focal}, i) do
    (box_n + 1) * (i + 1) * focal
  end
end
