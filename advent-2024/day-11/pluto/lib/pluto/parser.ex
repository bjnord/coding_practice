defmodule Pluto.Parser do
  @moduledoc """
  Parsing for `Pluto`.
  """

  @type stone_map() :: %{integer() => integer()}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a map of stone counts
  """
  @spec parse_input_file(String.t()) :: stone_map()
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

  a map of stone counts

  ## Examples
      iex> parse_input_string("125 17\n")
      %{125 => 1, 17 => 1}
  """
  @spec parse_input_string(String.t()) :: stone_map()
  def parse_input_string(input) do
    input
    |> String.trim_trailing()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&({&1, 1}))
    |> Enum.into(%{})
  end
end
