defmodule Cucumber.Herd do
  @moduledoc """
  Herd structure for `Cucumber`.
  """

  alias Cucumber.Herd

  defstruct dimx: 0, dimy: 0, grid: {}, east: [], south: []

  @doc ~S"""
  Construct a new herd from `input`.

  ## Examples
      iex> Cucumber.Herd.new(".>.\n..v\n")
      %Cucumber.Herd{dimx: 3, dimy: 2, east: [{1, 0}], south: [{2, 1}],
        grid: {{:floor, :east, :floor}, {:floor, :floor, :south}}}
  """
  def new(input) do
    grid = parse(input)
    [dimx] = row_widths(grid)
    dimy = tuple_size(grid)
    %Herd{
      grid: grid,
      dimx: dimx,
      dimy: dimy,
      east: grid_positions(grid, {dimx, dimy}, :east),
      south: grid_positions(grid, {dimx, dimy}, :south),
    }
  end

  defp row_widths(grid) do
    for row <- Tuple.to_list(grid),
      uniq: true,
      do: tuple_size(row)
  end

  defp grid_positions(grid, {dimx, dimy}, kind) do
    for y <- 0..dimy-1, x <- 0..dimx-1 do
      if elem(elem(grid, y), x) == kind, do: {x, y}, else: nil
    end
    |> Enum.reject(&(&1 == nil))
  end

  @doc false
  def east_pos(herd), do: Enum.sort(herd.east)

  @doc false
  def south_pos(herd), do: Enum.sort(herd.south)

  @doc false
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> List.to_tuple()
  end

  defp parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(&to_kind/1)
    |> List.to_tuple()
  end

  defp to_kind(char) do
    case char do
      ?> -> :east
      ?v -> :south
      ?. -> :floor
    end
  end
end
