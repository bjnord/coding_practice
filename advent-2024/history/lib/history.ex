defmodule History do
  @moduledoc """
  Documentation for `History`.
  """

  @doc ~S"""
  Flatten a multi-dimensional list to a 2D list.

  The deepest lists will be preserved as elements in a returned (flat) list.

  Thanks to the folks on
  [Elixir Forum](https://elixirforum.com/t/flatten-multi-dimensional-to-2-dimensional/67944/2)
  for suggestions that cleaned this up nicely!

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
    Enum.flat_map(list, &flatten_2d/1)
  end
  def flatten_2d(list) when is_list(list), do: list

  @doc ~S"""
  Count occurrences of items in a list.

  ## Returns

  a map of items (keys) and counts (values)

  ## Examples
      iex> tally([1, 2, 3, 5, 3, 5, 8, 13, 8, 3, 21, 5, 1])
      %{1 => 2, 2 => 1, 3 => 3, 5 => 3, 8 => 2, 13 => 1, 21 => 1}
  """
  @spec tally([]) :: %{any() => non_neg_integer()}
  def tally(list) do
    Enum.reduce(list, %{}, fn entry, acc -> Map.update(acc, entry, 1, &(&1 + 1)) end)
  end
end
