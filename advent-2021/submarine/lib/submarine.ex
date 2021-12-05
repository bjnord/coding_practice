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

  @doc """
  Return the delta used to step from integer `a` to `b`.

  (Elixir doesn't seem to have a built-in operator or function for this? Surprising.)

  ## Examples
      iex> Submarine.step_delta(0, 5)
      1
      iex> Submarine.step_delta(2, 2)
      0
      iex> Submarine.step_delta(2, -2)
      -1
  """
  def step_delta(a, b) do
    cond do
      a < b -> 1
      a == b -> 0
      a > b -> -1
    end
  end
end
