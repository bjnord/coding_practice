defmodule Diagnostic.Parser do
  @moduledoc """
  Parsing for `Diagnostic`.
  """

  use Bitwise

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&Diagnostic.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&Diagnostic.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a binary number.

  Returns list of integer bit values

  ## Examples
      iex> Diagnostic.Parser.parse_line("00010\n")
      [0, 0, 0, 1, 0]
      iex> Diagnostic.Parser.parse_line("11110\n")
      [1, 1, 1, 1, 0]
  """
  def parse_line(line) do
    line
    |> String.trim_trailing
    |> String.to_charlist
    |> Enum.map(fn b -> b &&& 1 end)
  end
end
