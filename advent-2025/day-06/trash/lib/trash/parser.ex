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
  defp parse_input_string_part2(input) do
    lines = String.split(input, "\n", trim: true)
    breakpoints = find_breakpoints(lines)
    lines
    |> Enum.map(fn line -> break_line(line, breakpoints) end)
    |> then(&transpose/1)
    |> Enum.map(&parse_stripe/1)
    |> Enum.reverse()
  end

  @doc """
  Find the column indexes which have a space in all lines.
  """
  @spec find_breakpoints([String.t()]) :: [integer()]
  def find_breakpoints(lines) do
    lines
    |> map_column_nonspaces()
    |> Enum.filter(fn {_i, n_nonspace} -> n_nonspace == 0 end)
    |> Enum.map(fn kv -> elem(kv, 0) end)
    |> Enum.sort()
  end

  # produce a Map in which:
  # - key: column index
  # - value: number of non-space characters in the column
  defp map_column_nonspaces(lines) do
    lines
    |> Enum.map(&String.to_charlist/1)
    |> Enum.reduce(%{}, fn charlist, map ->
      charlist
      |> Enum.with_index()
      |> Enum.reduce(map, fn {ch, i}, map ->
        case ch do
          32 -> Map.put_new(map, i, 0)
          _  -> Map.update(map, i, 1, fn n -> n + 1 end)
        end
      end)
    end)
  end

  @doc """
  Break a line into charlist tokens, at the given column breakpoints.

  Examples
      iex> Trash.Parser.break_line("ABRA CADABRA HOCUS POCUS", [4, 12, 18])
      [~c"ABRA ", ~c"CADABRA ", ~c"HOCUS ", ~c"POCUS"]
  """
  @spec break_line(String.t(), [integer()]) :: [charlist()]
  def break_line(line, breakpoints) do
    line
    |> String.to_charlist()
    |> break_tokens([], breakpoints, 0)
  end

  defp break_tokens(charlist, tokens, [], _) do
    [charlist | tokens]
    |> Enum.reverse()
  end
  defp break_tokens(charlist, tokens, [next_bp | breakpoints], n_removed) do
    {left, right} = Enum.split(charlist, (next_bp + 1) - n_removed)
    break_tokens(right, [left | tokens], breakpoints, next_bp + 1)
  end

  # a "stripe" is a vertical column group, representing one equation
  # in the part 2 rules -- the stripe for `356 * 24 * 1` is:
  #
  # ```
  # 123
  #  45
  #   6
  # *  
  # ```
  defp parse_stripe(stripe) do
    [operation | operands] = Enum.reverse(stripe)
    operation =
      operation
      |> List.to_string()
      |> String.trim()
      |> String.to_atom()
    operands =
      operands
      |> then(&transpose/1)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.map(&List.to_string/1)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(fn s -> s == "" end)
      |> Enum.map(&String.to_integer/1)
      |> Enum.reverse()
    {operands, operation}
  end

  @doc """
  Given a 2D list-of-lists, turn columns into rows.
  """
  def transpose(list_2d) do
    list_2d
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
