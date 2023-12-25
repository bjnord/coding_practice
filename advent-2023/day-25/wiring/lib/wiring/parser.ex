defmodule Wiring.Parser do
  @moduledoc """
  Parsing for `Wiring`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of component wirings (tuples).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.flat_map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of component wirings (tuples).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.flat_map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a component wiring description.

  Returns a list of component wirings (tuples).

  ## Examples
      iex> parse_line("aaa: bbb\n")
      [{"aaa", "bbb"}]
      iex> parse_line("ccc: ddd eee fff\n")
      [{"ccc", "ddd"}, {"ccc", "eee"}, {"ccc", "fff"}]
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(": ")
    |> then(fn [left, rights] ->
      rights
      |> String.split()
      |> Enum.reduce([], fn right, acc ->
        [{left, right} | acc]
      end)
      |> Enum.reverse()
    end)
  end
end
