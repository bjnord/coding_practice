defmodule Scratch.Parser do
  @moduledoc """
  Parsing for `Scratch`.
  """

  alias Scratch.Card

  @doc ~S"""
  Parse the input file.

  Returns a list of `Card`s.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Card`s.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing scratch card numbers.

  Returns a `Card`.

  ## Examples
      iex> parse_line("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53\n")
      %Scratch.Card{number: 1, winning: [41, 48, 83, 86, 17], have: [83, 86, 6, 31, 17, 9, 48, 53]}
  """
  def parse_line(line) do
    [card_n_str, numbers_str] =
      line
      |> String.trim_trailing()
      |> String.split(":")
    [winning_str, have_str] =
      numbers_str
      |> String.split("|")
    %Card{
      number: parse_card_n(card_n_str),
      winning: parse_numbers(winning_str),
      have: parse_numbers(have_str),
    }
  end

  # "Card 1"
  defp parse_card_n(card_n_str) do
    card_n_str
    |> String.split()
    |> List.last()
    |> String.to_integer()
  end

  # "83 86  6 31 17  9 48 53"
  defp parse_numbers(numbers_str) do
    numbers_str
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
