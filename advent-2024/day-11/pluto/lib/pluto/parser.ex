defmodule Pluto.Parser do
  @moduledoc """
  Parsing for `Pluto`.
  """

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of stones
  """
  @spec parse_input_file(String.t()) :: [integer()]
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

  a list of stones

  ## Examples
      iex> parse_input_string("125 17\n")
      [125, 17]
  """
  @spec parse_input_string(String.t()) :: [integer()]
  def parse_input_string(input) do
    input
    |> String.trim_trailing()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
