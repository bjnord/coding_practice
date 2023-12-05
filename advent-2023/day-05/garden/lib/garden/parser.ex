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
  def parse_input_string(input, _opts \\ []) do
    blocks =
      input
      |> String.split("\n\n", trim: true)
    seeds =
      blocks
      |> List.first()
      |> parse_seeds_line()
    gmaps =
      blocks
      |> Enum.drop(1)
      |> Enum.map(&parse_gmap_block/1)
    {seeds, gmaps}
  end

  @doc ~S"""
  Parse an input line containing a list of seeds.

  Returns a list of integer seeds.

  ## Examples
      iex> parse_seeds_line("seeds: 79 14 55 13\n")
      [79, 14, 55, 13]
  """
  def parse_seeds_line(line) do
    line
    |> String.trim_trailing()
    |> String.split()
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
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
