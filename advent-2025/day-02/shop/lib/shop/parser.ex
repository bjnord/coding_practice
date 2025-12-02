defmodule Shop.Parser do
  @moduledoc """
  Parsing for `Shop`.
  """

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of product ID ranges
  """
  @spec parse_input_file(String.t()) :: [Shop.product_range()]
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

  a list of product ID ranges

  ## Examples
      iex> parse_input_string("11-22,95-115\n")
      [{11, 22}, {95, 115}]
  """
  @spec parse_input_string(String.t()) :: [Shop.product_range()]
  def parse_input_string(input) do
    input
    |> String.trim_trailing()
    |> String.split(",", trim: true)
    |> Enum.map(&parse_range/1)
  end

  @doc ~S"""
  Parse a product ID range string.

  ## Parameters

  - `range`: the product ID range string

  ## Returns

  a product ID range

  ## Examples
      iex> parse_range("70-86")
      {70, 86}
      iex> parse_range("95-115")
      {95, 115}
  """
  @spec parse_range(String.t()) :: Shop.product_range()
  def parse_range(range) do
    range
    |> String.split("-")
    |> then(fn [a, b] ->
      {String.to_integer(a), String.to_integer(b)}
    end)
  end
end
