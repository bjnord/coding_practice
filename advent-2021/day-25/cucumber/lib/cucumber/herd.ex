defmodule Cucumber.Herd do
  @moduledoc """
  Herd structure for `Cucumber`.
  """

  alias Cucumber.Herd

  defstruct dimx: 0, dimy: 0, grid: {}

  @doc ~S"""
  Construct a new herd from `input`.

  ## Examples
      iex> Cucumber.Herd.new(".>.\nv..\n")
      %Cucumber.Herd{dimx: 3, dimy: 2, grid: {{:floor, :east, :floor}, {:south, :floor, :floor}}}
  """
  def new(input) do
    grid = parse(input)
    [dimx] = row_widths(grid)
    %Herd{
      grid: grid,
      dimx: dimx,
      dimy: tuple_size(grid),
    }
  end

  defp row_widths(grid) do
    for row <- Tuple.to_list(grid),
      uniq: true,
      do: tuple_size(row)
  end

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
