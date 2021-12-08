defmodule Segment.Parser do
  @moduledoc """
  Parsing for `Segment`.
  """

  use Bitwise

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&Segment.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&Segment.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a note.

  Returns `{signal_patterns, output_values}` where both are a list of strings
  """
  def parse_line(line) do
    line
    |> String.trim_trailing
    |> String.split(" | ")
    |> Enum.map(&String.split/1)
    |> List.to_tuple()
  end
end
