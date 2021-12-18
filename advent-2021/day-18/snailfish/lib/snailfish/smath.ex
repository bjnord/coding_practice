defmodule Snailfish.Smath do
  @moduledoc """
  Math for `Snailfish`.
  """

  @doc ~S"""
  Add snailfish numbers.

  ## Examples
      iex> Snailfish.Smath.add(["[1,2]", "[[3,4],5]"])
      "[[1,2],[[3,4],5]]"
  """
  def add([n]), do: n
  def add([n1, n2]) do
    "[#{n1},#{n2}]"
    # TODO handle reduction here
  end
  def add([n1 | [n2 | numbers]]), do: add([add([n1, n2]) | numbers])
end
