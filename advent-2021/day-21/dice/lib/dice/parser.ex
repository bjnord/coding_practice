defmodule Dice.Parser do
  @moduledoc """
  Parsing for `Dice`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(&(Enum.at(&1, 4)))
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
