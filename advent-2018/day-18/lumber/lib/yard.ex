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
        {42, 7} => :trees,
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
      "|" -> :trees
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

  def parse_lines(lines, _opts \\ []) do
    lines
    |> Enum.reduce({0, %{}}, fn (line, {y, grid}) ->
      {y+1, parse_line(line, y, grid)}
    end)
    |> elem(1)
    |> Yard.new()
  end

  @doc """
  Generate printable map of a yard.
  """
  @spec map(Yard.t()) :: [String.t()]

  def map(yard) do
    for y <- y_range(yard),
      do: map_row(yard, y, x_range(yard))
  end

  defp y_range(yard) do
    0..(elem(yard.size, 0)-1)
  end

  defp x_range(yard) do
    0..(elem(yard.size, 1)-1)
  end

  @spec map_row(Yard.t(), integer(), Range.t(integer())) :: String.t()

  defp map_row(yard, y, x_range) do
    row =
      for x <- x_range,
        do: map_position(yard, {y, x})
    row
    |> to_string()
  end

  @spec map_position(Yard.t(), position()) :: integer()

  defp map_position(yard, position) do
    case yard.grid[position] do
      :open -> ?.
      :trees -> ?|
      :lumber -> ?#
    end
  end

  @doc """
  Find counts of surrounding grid cells.

  ## Examples

      iex> yard = Yard.parse_lines([
      ...>   ".#|#.",
      ...>   "..#..",
      ...>   ".|..|",
      ...>   "..|#.",
      ...>   "#.#||",
      ...> ])
      iex> Yard.surrounding_counts(yard, {0, 0})
      %{open: 2, trees: 0, lumber: 1}
      iex> Yard.surrounding_counts(yard, {1, 1})
      %{open: 4, trees: 2, lumber: 2}
      iex> Yard.surrounding_counts(yard, {4, 4})
      %{open: 1, trees: 1, lumber: 1}
  """
  @spec surrounding_counts(Yard.t(), position()) :: map()

  def surrounding_counts(yard, {y, x}) do
    contents =
      for j <- (y-1)..(y+1),
        i <- (x-1)..(x+1),
        j != y or i != x,
        do: yard.grid[{j, i}]
    contents
    |> Enum.reject(&(&1 == nil))
    |> Enum.reduce(%{open: 0, trees: 0, lumber: 0}, fn (content, counts) ->
      Map.update(counts, content, 1, &(&1 + 1))
    end)
  end

  @doc """
  Iterate.

  "Strange magic is at work here: each minute, the landscape looks
  entirely different."
  """
  @spec strange_magic(Yard.t(), integer(), map()) :: [String.t()]

  def strange_magic(yard, minutes, opts \\ []) do
    1..minutes
    |> Enum.reduce(yard, fn (m, yard) ->
      new_grid =
        for j <- y_range(yard),
          i <- x_range(yard),
          do: {{j, i}, new_content(yard, {j, i})},
          into: %{}
      %{yard | grid: new_grid}
    end)
  end

  defp new_content(yard, {y, x}) do
    now = yard.grid[{y, x}]
    surr = surrounding_counts(yard, {y, x})
#   if {y, x} == {0, 0} do
#     IO.inspect({now, surr, surr[:trees]}, label: "now,surround,n_trees at {0, 0}")
#   end
    cond do
      (now == :open) and (surr[:trees] >= 3) ->
        :trees
      (now == :trees) and (surr[:lumber] >= 3) ->
        :lumber
      (now == :lumber) and (surr[:lumber] >= 1) and (surr[:trees] >= 1) ->
        :lumber
      (now == :lumber) ->
        :open
      true ->
        now
    end
  end
end
