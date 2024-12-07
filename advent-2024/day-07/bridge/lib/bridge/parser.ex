defmodule Bridge.Parser do
  @moduledoc """
  Parsing for `Bridge`.
  """

  @opaque streamable(t) :: list(t) | Enum.t | Enumerable.t

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of equations
  """
  @spec parse_input_file(String.t()) :: streamable([[integer()]])
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

  a list of equations

  ## Examples
      iex> parse_input_string("55: 5 11\n21: 8 13\n") |> Enum.to_list()
      [{55, [5, 11]}, {21, [8, 13]}]
  """
  @spec parse_input_string(String.t()) :: streamable([[integer()]])
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing an equation.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  an equation

  ## Examples
      iex> parse_line("99: 9 11\n")
      {99, [9, 11]}
      iex> parse_line("10: 1 2 3 4\n")
      {10, [1, 2, 3, 4]}
  """
  @spec parse_line(String.t()) :: [integer()]
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(~r{[\s:]+})
    |> Enum.map(&String.to_integer/1)
    |> then(fn [h | t] -> {h, t} end)
  end
end
