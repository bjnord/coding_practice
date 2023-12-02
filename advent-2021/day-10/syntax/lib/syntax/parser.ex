defmodule Syntax.Parser do
  @moduledoc """
  Parsing for `Syntax`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of charlists (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of charlists (one per line).

  ## Examples
      iex> parse_input_string("{()()()}\n{()()()>\n") |> Enum.to_list()
      ['{()()()}', '{()()()>']
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a navigation subsystem entry.

  Returns a charlist.

  ## Examples
      iex> parse_line("{()()()}\n")
      '{()()()}'
      iex> parse_line("{()()()>\n")
      '{()()()>'
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
  end
end
