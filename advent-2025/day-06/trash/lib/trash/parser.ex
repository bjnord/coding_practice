defmodule Trash.Parser do
  @moduledoc """
  Parsing for `Trash`.
  """

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  an equation list
  """
  @spec parse_input_file(String.t()) :: [Trash.equation()]
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

  an equation list
  """
  @spec parse_input_string(String.t()) :: [Trash.equation()]
  def parse_input_string(input) do
    input
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ~r{\s+}, trim: true) end)
    |> then(&transpose/1)
    |> Enum.map(&parse_equation/1)
  end

  # turn columns into rows
  defp transpose(lines) do
    lines
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp parse_equation(tokens) do
    [token1 | tokens] = Enum.reverse(tokens)
    operands =
      Enum.reverse(tokens)
      |> Enum.map(&String.to_integer/1)
    {
      operands,
      String.to_atom(token1),
    }
  end
end
