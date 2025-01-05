defmodule Keypad.Parser do
  @moduledoc """
  Parsing for `Keypad`.
  """

  @opaque streamable(t) :: list(t) | Enum.t() | Enumerable.t()
  @type code() :: [char()]

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of codes
  """
  @spec parse_input_file(String.t()) :: streamable(code())
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

  a list of codes
  """
  @spec parse_input_string(String.t()) :: streamable(code())
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a code.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  the code

  ## Examples
      iex> parse_line("867A\n")
      ~c"867A"
      iex> parse_line("530A\n")
      ~c"530A"
  """
  @spec parse_line(String.t()) :: code()
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
  end
end
