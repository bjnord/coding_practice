defmodule Lift.Parser do
  @moduledoc """
  Parsing for `Lift`.
  """

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path
  """
  def parse_input_file(path, _opts \\ []) do
    path
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Examples
      iex> parse_input_string("12345\n97531\n") |> Enum.to_list()
      ['12345', '97531']
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a battery bank.

  Returns a charlist.

  ## Examples
      iex> parse_line("23456\n")
      '23456'
      iex> parse_line("86420\n")
      '86420'
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
  end
end
