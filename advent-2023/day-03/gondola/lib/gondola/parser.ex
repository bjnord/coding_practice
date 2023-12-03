defmodule Gondola.Parser do
  @moduledoc """
  Parsing for `Gondola`.
  """

  alias Gondola.Schematic, as: Schematic

  @doc ~S"""
  Parse the input file.

  Returns a `Schematic`.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
    |> build_schematic()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a `Schematic`.
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
    |> build_schematic()
  end

  @doc ~S"""
  Parse an input line containing part number(s) and/or symbol(s).

  Returns a map with the following elements:
  - `parts`: list of parts found on line (with x positions)
  - `symbols`: list of symbols found on line (with x position)

  ## Examples
      iex> parse_line(".633..633.\n")
      %{parts: [%{number: 633, x1: 1, x2: 3}, %{number: 633, x1: 6, x2: 8}], symbols: []}
      iex> parse_line("617*......\n")
      %{parts: [%{number: 617, x1: 0, x2: 2}], symbols: [%{symbol: "*", x: 3}]}
      iex> parse_line("....@.@...\n")
      %{parts: [], symbols: [%{symbol: "@", x: 4}, %{symbol: "@", x: 6}]}
      iex> parse_line("......=555\n")
      %{parts: [%{number: 555, x1: 7, x2: 9}], symbols: [%{symbol: "=", x: 6}]}
  """
  def parse_line(line) do
    acc0 = %{
      parts: [],
      symbols: [],
      part_n: 0,
      x1: nil,
    }
    acc =
      line
      |> String.replace_trailing("\n", ".")
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(acc0, fn {ch, x}, acc ->
        cond do
          digit?(ch) ->
            accumulate_part_number(acc, ch, x)
          dot?(ch) ->
            emit_part_number(acc, x)
          true ->  # symbol
            emit_symbol(acc, ch, x)
            |> emit_part_number(x)
        end
      end)
    %{
      parts: Enum.reverse(acc.parts),
      symbols: Enum.reverse(acc.symbols),
    }
  end

  defp digit?(ch) when (ch >= ?0) and (ch <= ?9), do: true
  defp digit?(_ch), do: false
  defp dot?(ch) when ch == ?., do: true
  defp dot?(_ch), do: false

  defp accumulate_part_number(acc, ch, x) do
    x1 = if acc.x1, do: acc.x1, else: x
    %{acc | part_n: acc.part_n * 10 + (ch - ?0), x1: x1}
  end
  defp emit_part_number(acc, x) do
    if acc.x1 do
      parts = [%{number: acc.part_n, x1: acc.x1, x2: x - 1} | acc.parts]
      %{acc | parts: parts, part_n: 0, x1: nil}
    else
      acc
    end
  end
  defp emit_symbol(acc, ch, x) do
    s = List.to_string([ch])
    symbols = [%{symbol: s, x: x} | acc.symbols]
    %{acc | symbols: symbols}
  end

  # Transform a list of line contents into a `Schematic`.
  defp build_schematic(line_maps) do
    line_maps
    |> Enum.with_index(fn line_map, y ->
      parts =
        line_map.parts
        |> Enum.map(fn part -> Map.put(part, :y, y) end)
      symbols =
        line_map.symbols
        |> Enum.map(fn symbol -> Map.put(symbol, :y, y) end)
      %{
        parts: parts,
        symbols: symbols,
      }
    end)
    |> Enum.reduce(%Schematic{}, fn line_map, sch ->
      # OPTIMIZE `++` is inefficient
      %Schematic{
        parts: sch.parts ++ line_map.parts,
        symbols: sch.symbols ++ line_map.symbols,
      }
    end)
  end
end
