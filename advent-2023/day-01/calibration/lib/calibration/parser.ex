defmodule Calibration.Parser do
  @moduledoc """
  Parsing for `Calibration`.
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
      iex> parse_input_string("1two3\nfour5six\n") |> Enum.to_list()
      ['1two3', 'four5six']
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a calibration value.

  Returns a charlist.

  ## Examples
      iex> parse_line("xyzzy7plugh92")
      'xyzzy7plugh92'
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
  end
end
