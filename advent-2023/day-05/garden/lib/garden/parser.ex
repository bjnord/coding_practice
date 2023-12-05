defmodule Garden.Parser do
  @moduledoc """
  Parsing for `Garden`.
  """

  alias Garden.Gmap

  @doc ~S"""
  Parse the input file.

  Returns a tuple containing:
  - a list of integer seeds
  - a list of `Gmap`s
  """
  def parse_input(input_file, opts \\ []) do
    File.read!(input_file)
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a tuple containing:
  - a list of integer seeds
  - a list of `Gmap`s
  """
  def parse_input_string(input, opts \\ []) do
    blocks =
      input
      |> String.split("\n\n", trim: true)
    seeds =
      blocks
      |> List.first()
      |> parse_seeds_line(opts)
    gmaps =
      blocks
      |> Enum.drop(1)
      |> Enum.map(&parse_gmap_block/1)
      |> Enum.map(fn gmap -> {gmap.from, gmap} end)
      |> Enum.into(%{})
    {seeds, gmaps}
  end

  @doc ~S"""
  Parse an input line containing a list of seeds.

  This produces a different result depending on the puzzle part rules.

  ## Parameters

  - `part` keyword (1 or 2)

  Returns a list of integer seeds.

  ## Examples
      iex> parse_seeds_line("seeds: 79 14 55 13\n", part: 1)
      [{79, 1}, {14, 1}, {55, 1}, {13, 1}]
      iex> parse_seeds_line("seeds: 79 14 55 13\n", part: 2)
      [{79, 14}, {55, 13}]
  """
  def parse_seeds_line(line, opts \\ []) do
    numbers =
      line
      |> String.trim_trailing()
      |> String.split()
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    if opts[:part] == 2 do
      numbers
      |> Enum.chunk_every(2)
      |> Enum.map(fn pair -> List.to_tuple(pair) end)
    else
      numbers
      |> Enum.map(fn n -> {n, 1} end)
    end
  end

  @doc ~S"""
  Parse a list of input lines containing a garden map.

  Returns a `Gmap`.
  """
  def parse_gmap_block(block) do
    lines =
      block
      |> String.trim_trailing()
      |> String.split("\n")
    {from, to} =
      lines
      |> List.first()
      |> parse_gmap_type_line()
    maps =
      lines
      |> Enum.drop(1)
      |> Enum.map(&parse_gmap_line/1)
    %Gmap{
      from: from,
      to: to,
      maps: maps,
    }
  end

  # "seed-to-soil map:"
  defp parse_gmap_type_line(line) do
    {from, _, to} =
      line
      |> String.split()
      |> List.first()
      |> String.split("-")
      |> Enum.map(&String.to_atom/1)
      |> List.to_tuple()
    {from, to}
  end

  @doc ~S"""
  Parse an input line containing a range map.

  The range map is three values:
  - destination range start
  - source range start
  - range length

  Returns a map representing the range map.

  ## Examples
      iex> parse_gmap_line("50 98 2\n")
      %{to: 50, from: 98, length: 2}
  """
  def parse_gmap_line(line) do
    {dest_start, source_start, len} =
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    %{to: dest_start, from: source_start, length: len}
  end
end
