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
    |> Enum.reduce(%{}, fn instruction, boxes ->
      lens_op(boxes, instruction)
    end)
  end

  defp lens_op(boxes, {box_n, :install, i_label, i_focal}) do
    Map.get(boxes, box_n, [])
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
    |> then(fn lenses -> Map.put(boxes, box_n, lenses) end)
  end

  defp lens_op(boxes, {box_n, :remove, r_label}) do
    Map.get(boxes, box_n, [])
    |> Enum.reduce([], fn {label, focal}, lenses ->
      if label == r_label do
        # remove
        lenses
      else
        [{label, focal} | lenses]
      end
    end)
    |> Enum.reverse()
    |> then(fn lenses -> Map.put(boxes, box_n, lenses) end)
  end
end
