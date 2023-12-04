defmodule Scratch.Card do
  @moduledoc """
  Card structure and functions for `Scratch`.
  """

  defstruct number: 0, winning: [], have: []

  @doc """
  Find point value of `Card`.
  """
  def value(card) do
    matches =
      card.have
      |> Enum.sort()
      |> Enum.filter(fn have ->
        Enum.find(card.winning, fn win -> win == have end)
      end)
      |> Enum.count()
    if matches > 0, do: 2 ** (matches - 1), else: 0
  end
end
