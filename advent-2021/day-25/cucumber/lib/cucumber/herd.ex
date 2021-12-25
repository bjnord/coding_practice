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
      if content_at(grid, {x, y}) == kind, do: {x, y}, else: nil
    end
    |> Enum.reject(&(&1 == nil))
  end

  defp content_at(grid, {x, y}) do
    elem(elem(grid, y), x)
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

  @doc ~S"""
  Move the given herd `n` times.
  """
  def move(herd, n) do
    Enum.reduce(1..n, herd, fn (_n, herd) -> move(herd) end)
  end

  @doc ~S"""
  Move the given herd once.

  ## Examples
      iex> Cucumber.Herd.new(".>.\n..v\n") |> Cucumber.Herd.move(1)
      %Cucumber.Herd{dimx: 3, dimy: 2, east: [{2, 0}], south: [{2, 1}],
        grid: {{:floor, :floor, :east}, {:floor, :floor, :south}}}
  """
  # FIXME once working, make this `defp` or `@doc false`
  def move(herd) do
    # "Every step, the sea cucumbers in the east-facing herd attempt to
    # move forward one location, then the sea cucumbers in the south-facing
    # herd attempt to move forward one location. [...] During a single step,
    # the east-facing herd moves first, then the south-facing herd moves."
    move_east(herd)
    |> move_south()
  end

  defp move_east(herd) do
    {grid, east} = move_cucumbers(herd, :east, herd.east)
    %Herd{herd | grid: grid, east: east}
  end

  defp move_south(herd) do
    {grid, south} = move_cucumbers(herd, :south, herd.south)
    %Herd{herd | grid: grid, south: south}
  end

  defp move_cucumbers(herd, kind, positions) do
    # "When a herd moves forward, every sea cucumber in the herd first
    # simultaneously considers whether there is a sea cucumber in the
    # adjacent location it's facing (even another sea cucumber facing the
    # same direction), and then every sea cucumber facing an empty
    # location simultaneously moves into that location."
    ###
    # first look and decide (computing what all new positions will be):
    {moves, new_positions} =
      positions
      |> Enum.reduce({[], []}, fn (pos, {moves, new_positions}) ->
        new_pos = new_pos(kind, pos, {herd.dimx, herd.dimy})
        if content_at(herd.grid, new_pos) == :floor do
          {[{pos, new_pos} | moves], [new_pos | new_positions]}
        else
          {moves, [pos | new_positions]}
        end
      end)
    ###
    # then update the grid for those who are moving
    grid =
      moves
      |> Enum.reduce(herd.grid, fn ({pos, new_pos}, grid) ->
        move_cucumber(grid, kind, pos, new_pos)
      end)
    ###
    # and return new grid and positions:
    {grid, new_positions}
  end

  defp new_pos(kind, {x, y}, {dimx, dimy}) do
    case kind do
      :east ->
        {rem(x + 1, dimx), y}
      :south ->
        {x, rem(y + 1, dimy)}
    end
  end

  defp move_cucumber(grid, kind, {x, y}, {new_x, new_y}) do
    grid
    |> set_content({x, y}, :floor)
    |> set_content({new_x, new_y}, kind)
  end

  defp set_content(grid, {x, y}, content) do
    new_row = put_elem(elem(grid, y), x, content)
    put_elem(grid, y, new_row)
  end
end
