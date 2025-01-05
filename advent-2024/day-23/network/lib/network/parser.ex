defmodule Network.Parser do
  @moduledoc """
  Parsing for `Network`.
  """

  @opaque streamable(t) :: list(t) | Enum.t() | Enumerable.t()
  @type network() :: {String.t(), String.t()}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of network connections
  """
  @spec parse_input_file(String.t()) :: streamable(network())
  def parse_input_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of network connections
  """
  @spec parse_input_string(String.t()) :: streamable(network())
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a network connection.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a network connection

  ## Examples
      iex> parse_line("br-ad\n")
      {"br", "ad"}
  """
  @spec parse_line(String.t()) :: network()
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split("-")
    |> List.to_tuple()
  end
end
