defmodule Trash.Parser do
  @moduledoc """
  Parsing for `Trash`.
  """

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path
  - `opts` - `part` keyword (1 or 2)

  ## Returns

  an equation list
  """
  @spec parse_input_file(String.t(), [part: pos_integer()]) :: [Trash.equation()]
  def parse_input_file(path, opts) do
    path
    |> File.read!()
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse an input string.

  The parser behaves differently for parts 1 and 2; see puzzle description.

  ## Parameters

  - `input`: the puzzle input
  - `opts` - `part` keyword (1 or 2)

  ## Returns

  an equation list
  """
  @spec parse_input_string(String.t(), [part: pos_integer()]) :: [Trash.equation()]
  def parse_input_string(input, opts) do
    case opts[:part] do
      1 -> parse_input_string_part1(input)
      2 -> parse_input_string_part2(input)
    end
  end

  @spec parse_input_string_part1(String.t()) :: [Trash.equation()]
  defp parse_input_string_part1(input) do
    input
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ~r{\s+}, trim: true) end)
    |> then(&transpose/1)
    |> Enum.map(&parse_equation/1)
  end

  @spec parse_input_string_part2(String.t()) :: [Trash.equation()]
  defp parse_input_string_part2(_input) do
    # TODO
    [
      {[1, 2], :+},
    ]
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
