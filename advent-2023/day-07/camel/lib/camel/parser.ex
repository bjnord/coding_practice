defmodule Camel.Parser do
  @moduledoc """
  Parsing for `Camel`.
  """

  alias Camel.Hand

  @doc ~S"""
  Parse the input file.

  Returns a list of `Hand`s.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Hand`s.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a Camel Cards hand.

  Returns a `Hand`.

  ## Examples
      iex> parse_line("32T3K 765\n")
      %Camel.Hand{ cards: [ 3,  2, 10,  3, 13], bid: 765, type: :pair1, type_i: 1 }
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split()
    |> List.to_tuple()
    |> parse_hand()
  end

  @doc ~S"""
  Parse cards and bid.

  Returns a `Hand`.

  ## Examples
      iex> parse_hand({"T55J5", "684"})
      %Camel.Hand{ cards: [10,  5,  5, 11,  5], bid: 684, type: :kind3, type_i: 3 }
  """
  def parse_hand({cards_str, bid_str}) do
    cards = parse_cards(cards_str)
    {type, type_i} = classify_hand(cards)
    bid = String.to_integer(bid_str)
    %Hand{cards: cards, bid: bid, type: type, type_i: type_i}
  end

  defp parse_cards(cards_str) do
    cards_str
    |> String.graphemes()
    |> Enum.map(&card_value/1)
  end

  defp card_value(card) do
    case card do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "J" -> 11
      "T" -> 10
      _   -> String.to_integer(card)
    end
  end

  @doc ~S"""
  Classfy a hand.

  ## Parameters

  - `cards`: list of card values (integer 2-14)

  Returns a `{type, type_i}` tuple.

  ## Examples
      iex> classify_hand([10,  5,  5, 11,  5])
      {:kind3, 3}
  """
  def classify_hand(cards) do
    tally =
      cards
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)
    case tally do
      [5] ->
        {:kind5, 6}
      [4, 1] ->
        {:kind4, 5}
      [3, 2] ->
        {:fullh, 4}
      [3, 1, 1] ->
        {:kind3, 3}
      [2, 2, 1] ->
        {:pair2, 2}
      [2, 1, 1, 1] ->
        {:pair1, 1}
      _ ->
        {:highc, 0}
    end
  end
end
