defmodule Yard do
  @moduledoc """
  Documentation for Yard.
  """

  @enforce_keys [:grid, :size]
  defstruct grid: %{}, size: {nil, nil}

  @type position() :: {integer(), integer()}
  @type position_range() :: {Range.t(integer()), Range.t(integer())}
  @type t() :: %__MODULE__{
    grid: map(),
    size: position(),
  }

  @doc """
  Construct a new yard.
  """
  @spec new(map(), position()) :: Yard.t()

  def new(grid, {y, x}) when is_map(grid) and is_integer(y) and is_integer(x) do
    %Yard{grid: grid, size: {y, x}}
  end

  @spec new(map()) :: Yard.t()

  def new(grid) when is_map(grid) do
    y = Enum.map(grid, &(elem(elem(&1, 0), 0)))
        |> Enum.max
    x = Enum.map(grid, &(elem(elem(&1, 0), 1)))
        |> Enum.max
    new(grid, {y+1, x+1})
  end

  @doc ~S"""
  Parses a line from the initial state, adding its data to an accumulator.

  ## Example

      iex> Yard.parse_line(".#.#...|#.", 42, %{})
      %{
        {42, 0} => :open,
        {42, 1} => :lumber,
        {42, 2} => :open,
        {42, 3} => :lumber,
        {42, 4} => :open,
        {42, 5} => :open,
        {42, 6} => :open,
        {42, 7} => :wooded,
        {42, 8} => :lumber,
        {42, 9} => :open,
      }

  """
  def parse_line(line, y, grid) when is_binary(line) do
    line
    |> String.trim_trailing
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce(grid, fn ({cell, x}, grid_a) ->
      Map.put(grid_a, {y, x}, cell_type(cell))
    end)
  end

  defp cell_type(cell) do
    case cell do
      "." -> :open
      "|" -> :wooded
      "#" -> :lumber
    end
  end

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, opts \\ []) do
    input_file
    |> File.stream!
    |> parse_lines(opts)
  end

  defp parse_lines(stream, _opts) do
    stream
    |> Enum.reduce({0, %{}}, fn (line, {y, grid}) ->
      {y+1, parse_line(line, y, grid)}
    end)
    |> elem(1)
    |> Yard.new()
  end
end
