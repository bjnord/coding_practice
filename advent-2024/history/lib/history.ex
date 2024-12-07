defmodule History do
  @moduledoc """
  Documentation for `History`.
  """

  @doc ~S"""
  Flatten a multi-dimensional list to a 2D list.

  The deepest lists will be preserved as elements in a returned (flat) list.

  ## Parameters

  - the multi-dimensional list

  ## Returns

  a 2D list

  ## Examples
      iex> flatten_2d([[[[:a, :b],[:c, :d]],[[:e, :f],[:g, :h]]],[[[:i, :j],[:k, :l]],[[:m, :n],[:o, :p]]]])
      [[:a, :b], [:c, :d], [:e, :f], [:g, :h], [:i, :j], [:k, :l], [:m, :n], [:o, :p]]
  """
  @spec flatten_2d([[]]) :: [[]]
  def flatten_2d([h | t]) when is_list(h) do
    if is_list(List.first(h)) do
      [h | t]
      |> Enum.map(&flatten_2d/1)
      |> Enum.concat()
    else
      [h | t]
    end
  end
end
