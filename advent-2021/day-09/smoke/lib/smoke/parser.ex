defmodule Smoke.Parser do
  @moduledoc """
  Parsing for `Smoke`.
  """

  use Bitwise

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&Smoke.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&Smoke.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a binary number.

  Returns list of integer bit values

  ## Examples
      iex> Smoke.Parser.parse_line("21999\n")
      [2, 1, 9, 9, 9]
      iex> Smoke.Parser.parse_line("43210\n")
      [4, 3, 2, 1, 0]
  """
  def parse_line(line) do
    line
    |> String.trim_trailing
    |> String.to_charlist
    |> Enum.map(fn b -> b - ?0 end)
  end
end
