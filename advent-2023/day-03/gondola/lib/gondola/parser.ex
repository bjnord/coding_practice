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
      iex> parse_line("..35..633.\n")
      %{parts: [%{number: 35, x1: 2, x2: 3}, %{number: 633, x1: 6, x2: 8}], symbols: []}
      iex> parse_line("617*......\n")
      %{parts: [%{number: 617, x1: 0, x2: 2}], symbols: [%{symbol: "*", x: 3}]}
      iex> parse_line("....@.=...\n")
      %{parts: [], symbols: [%{symbol: "@", x: 4}, %{symbol: "=", x: 6}]}
  """
  def parse_line(line) do
    trimmed_line =
      line
      |> String.trim_trailing()
    parts =
      Regex.scan(~r{\b\d+\b}, trimmed_line)
      |> Enum.map(&hd/1)
      |> Enum.map(fn part_n ->
        # OPTIMIZE this kind of substring indexing is inefficient
        {i, len} = :binary.match line, part_n
        %{
          number: String.to_integer(part_n),
          x1: i,
          x2: i + len - 1,
        }
      end)
    symbols =
      Regex.scan(~r{[^\d\.]}, trimmed_line)
      |> Enum.map(&hd/1)
      |> Enum.map(fn symbol ->
        # OPTIMIZE this kind of substring indexing is inefficient
        {i, _len} = :binary.match line, symbol
        %{
          symbol: symbol,
          x: i,
        }
      end)
    %{
      parts: parts,
      symbols: symbols,
    }
  end

  @doc ~S"""
  Transform a list of line contents into a `Schematic`.
  """
  def build_schematic(line_maps) do
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
