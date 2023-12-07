defmodule Camel.Hand do
  @moduledoc """
  Hand structure and functions for `Camel`.
  """

  defstruct cards: [], bid: 0, type: nil, type_i: 0

  @doc ~S"""
  Calculate ranks of a list of hands.

  ## Parameters

  - `hands` - a list of `Hand`s

  Returns a list of ranks (integers 1-n) corresponding to each `Hand`.
  """
  def ranks(hands) do
    sorted_hands = Enum.sort(hands, &is_lesser?/2)
    hands
    |> Enum.map(fn hand ->
      i =
        sorted_hands
        |> Enum.with_index()
        |> Enum.find(fn {shand, _i} -> shand == hand end)
        |> elem(1)
      i + 1
    end)
  end

  defp is_lesser?(a, b), do: Camel.Hand.max(a, b) == b

  @doc ~S"""
  Calculate winnings.

  ## Parameters

  - `hands` - a list of `Hand`s
  - `ranks` - a list of ranks (integers 1-n) corresponding to each `Hand`

  Returns the winnings value (integer).
  """
  def winnings(hands, ranks) do
    Enum.zip(hands, ranks)
    |> Enum.map(fn {hand, rank} -> hand.bid * rank end)
    |> Enum.sum()
  end

  @doc ~S"""
  Compare two `Hand`s to find the stronger one.

  ## Parameters

  - `hand_a` - first `Hand` to compare
  - `hand_b` - second `Hand` to compare

  Returns the stronger `Hand`.
  """
  def max(hand_a, hand_b) do
    cond do
      hand_a.type_i > hand_b.type_i ->
        hand_a
      hand_b.type_i > hand_a.type_i ->
        hand_b
      true ->
        max_by_cards({hand_a, hand_a.cards}, {hand_b, hand_b.cards})
    end
  end

  defp max_by_cards({_, []}, {_, _}), do: raise "out of cards"
  defp max_by_cards({_, _}, {_, []}), do: raise "out of cards"
  defp max_by_cards({hand_a, [a | a_rem]}, {hand_b, [b | b_rem]}) do
    cond do
      a > b ->
        hand_a
      b > a ->
        hand_b
      true ->
        max_by_cards({hand_a, a_rem}, {hand_b, b_rem})
    end
  end
end
