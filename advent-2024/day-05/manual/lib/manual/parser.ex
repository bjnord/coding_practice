defmodule Manual.Parser do
  @moduledoc """
  Parsing for `Manual`.
  """

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a tuple with the rules and page sets
  """
  @spec parse_input_file(String.t()) :: {%{integer() => integer()}, [integer()]}
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a tuple with the rules and page sets

  ## Examples
      iex> parse_input_string("1|2\n3|5\n3|4\n\n1,2,3,4,5\n1,3,2\n")
      {%{1 => [2], 3 => [4, 5]}, [[1, 2, 3, 4, 5], [1, 3, 2]]}
  """
  @spec parse_input_string(String.t()) :: {%{integer() => integer()}, [integer()]}
  def parse_input_string(input) do
    [input_rules, input_page_sets] =
      input
      |> String.split("\n\n", trim: true)
    {
      parse_rules(input_rules),
      parse_page_sets(input_page_sets),
    }
  end

  def parse_rules(input_rules) do
    input_rules
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("|")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.update(acc, k, [v], &([v | &1]))
    end)
  end

  def parse_page_sets(input_page_sets) do
    input_page_sets
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_page_line/1)
  end

  @doc ~S"""
  Parse an input line containing page numbers.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a list of page numbers

  ## Examples
      iex> parse_page_line("2,3,4,1,5\n")
      [2, 3, 4, 1, 5]
      iex> parse_page_line("6,8,7\n")
      [6, 8, 7]
  """
  @spec parse_page_line(String.t()) :: [integer()]
  def parse_page_line(line) do
    line
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
