defmodule Cafe.Parser do
  @moduledoc """
  Parsing for `Cafe`.
  """

  @type ingredient() :: pos_integer()
  @type fresh_range() :: {pos_integer(), pos_integer()}
  @type inventory() :: {[fresh_range()], [ingredient()]}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  an inventory
  """
  @spec parse_input_file(String.t()) :: inventory()
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  an inventory
  """
  @spec parse_input_string(String.t()) :: inventory()
  def parse_input_string(input) do
    [fresh_ranges, ingredients] =
      input
      |> String.trim_trailing()
      |> String.split("\n\n", trim: true)
    {
      parse_fresh_ranges(fresh_ranges),
      parse_ingredients(ingredients),
    }
  end

  @doc ~S"""
  Parse an input section containing fresh ranges.

  ## Parameters

  - `section`: the puzzle input fresh ranges section

  ## Returns

  a list of fresh ranges

  ## Examples
      iex> parse_fresh_ranges("3-5\n10-14\n")
      [{3, 5}, {10, 14}]
  """
  @spec parse_fresh_ranges(String.t()) :: [fresh_range()]
  def parse_fresh_ranges(section) do
    section
    |> String.trim_trailing()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, "-")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  @doc ~S"""
  Parse an input section containing ingredients.

  ## Parameters

  - `section`: the puzzle input ingredients section

  ## Returns

  a list of ingredients

  ## Examples
      iex> parse_ingredients("1\n5\n8\n")
      [1, 5, 8]
  """
  @spec parse_ingredients(String.t()) :: [ingredient()]
  def parse_ingredients(section) do
    section
    |> String.trim_trailing()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
