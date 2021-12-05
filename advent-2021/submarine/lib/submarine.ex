defmodule Submarine do
  @moduledoc """
  Documentation for Submarine.
  """

  @doc """
  Transpose a two-dimensional list.

  h/t [this StackOverflow answer](https://stackoverflow.com/a/23706084/291754)

  ## Examples
      iex> Submarine.transpose([[1, 2], [3, 4], [5, 6]])
      [[1, 3, 5], [2, 4, 6]]
  """
  def transpose([[] | _]), do: []
  def transpose(a) do
      [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end
end
