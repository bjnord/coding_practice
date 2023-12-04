defmodule Scratch.Card do
  @moduledoc """
  Card structure and functions for `Scratch`.
  """

  defstruct number: 0, winning: [], have: []

  @doc """
  Find the point value of a `Card`.

  Returns the integer point value.
  """
  def value(card) do
    matches = matches(card)
    if matches > 0, do: 2 ** (matches - 1), else: 0
  end

  defp matches(card) do
    card.have
    |> Enum.filter(fn have ->
      Enum.find(card.winning, fn win -> win == have end)
    end)
    |> Enum.count()
  end

  @doc """
  Find the card copy counts for a list of `Card`s.

  Returns a map:
  - key is the card number
  - value is the number of copies of that card
  """
  def copies(cards) do
    matches =
      Enum.map(cards, fn card ->
        {card.number, matches(card)}
      end)
      |> Enum.into(%{})
    cards
    |> Enum.reduce(%{}, fn card, acc ->
      ###
      # first, record the original copy of this card
      acc = Map.update(acc, card.number, 1, &(&1 + 1))
      ###
      # second, record the duplicates of the next N cards
      card_numbers =
        if matches[card.number] && (matches[card.number] > 0) do
          (card.number + 1)..(card.number + matches[card.number])
        else
          []
        end
      # NB **each copy** of this card (`c`) will produce a copy of
      # the next N cards
      c = acc[card.number]
      card_numbers
      |> Enum.reduce(acc, fn card_n, acc ->
        Map.update(acc, card_n, c, &(&1 + c))
      end)
    end)
  end
end
