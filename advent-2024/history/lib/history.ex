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
  def flatten_2d(list) when is_list(hd(list)) and is_list(hd(hd(list))) do
    list
    |> Enum.map(&flatten_2d/1)
    |> Enum.concat()
  end
  def flatten_2d(list) when is_list(list), do: list
end
