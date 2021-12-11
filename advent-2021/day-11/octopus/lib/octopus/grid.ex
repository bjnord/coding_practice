defmodule Octopus.Grid do
  @moduledoc """
  Grid structure for `Octopus`.
  """

  defstruct dim: 0, grid: {}, flashes: 0

  @doc ~S"""
  Construct a new grid from 2D input.

  ## Examples
      iex> Octopus.Grid.new({{0, 1}, {2, 3}})
      %Octopus.Grid{dim: 2, grid: {{0, 1}, {2, 3}}, flashes: 0}
  """
  def new(input) do
    %Octopus.Grid{
      grid: input,
      dim: tuple_size(input),
    }
  end

  @doc ~S"""
  Return a list of all `{x, y}` positions for the given `grid`.

  ## Examples
      iex> Octopus.Grid.new({{0, 1}, {2, 3}}) |> Octopus.Grid.positions()
      [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
  """
  def positions(grid) do
    for y <- 0..grid.dim-1 do
      for x <- 0..grid.dim-1 do
        {x, y}
      end
    end
    |> List.flatten()
  end

  @doc ~S"""
  Return a list of all neighboring positions to `{x0, y0}`
  for a grid of the given `dim`.

  ## Examples
      iex> Octopus.Grid.neighbors({1, 1}, 3)
      [{0, 0}, {1, 0}, {2, 0}, {0, 1}, {2, 1}, {0, 2}, {1, 2}, {2, 2}]

      iex> Octopus.Grid.neighbors({2, 2}, 3)
      [{1, 1}, {2, 1}, {1, 2}]
  """
  def neighbors({x0, y0}, dim) do
    for dy <- -1..1 do
      for dx <- -1..1 do
        {x0 + dx, y0 + dy}
      end
    end
    |> List.flatten()
    |> Enum.reject(fn {x, y} -> x == x0 && y == y0 end)
    |> Enum.reject(fn {x, _y} -> x < 0 || x >= dim end)
    |> Enum.reject(fn {_x, y} -> y < 0 || y >= dim end)
  end

  @doc ~S"""
  Reset energy level to 0 for any `grid` position that flashed
  (_i.e._ is above 9).

  ## Examples
      iex> Octopus.Grid.new({{9, 10}, {13, 3}}) |> Octopus.Grid.reset_flashed_energy()
      %Octopus.Grid{dim: 2, grid: {{9, 0}, {0, 3}}}
  """
  def reset_flashed_energy(grid) do
    positions(grid)
    |> Enum.reduce(grid, fn (pos, grid) ->
      reset_energy_of_position(grid, pos)
    end)
  end

  @doc ~S"""
  Reset energy of the given `{x, y}` coordinate, if it's above 9.
  Returns updated `grid`.

  ## Examples
      iex> grid = Octopus.Grid.new({{0, 1, 18}, {3, 4, 5}, {6, 7, 2}})
      iex> Octopus.Grid.reset_energy_of_position(grid, {2, 0})
      %Octopus.Grid{grid: {{0, 1, 0}, {3, 4, 5}, {6, 7, 2}}, dim: 3}
  """
  def reset_energy_of_position(grid, {x, y}) do
    row = elem(grid.grid, y)
    if elem(row, x) > 9 do
      new_row = put_elem(row, x, 0)
      %{grid | grid: put_elem(grid.grid, y, new_row)}
    else
      grid
    end
  end

  @doc ~S"""
  Do one increase-energy step. Returns updated `grid`.
  """
  def increase_energy(grid) do
    {new_grid, flashed} =
      increase_energy_of_positions(grid, positions(grid))
    increase_neighbor_energy(%{new_grid | flashes: new_grid.flashes + Enum.count(flashed)}, flashed)
    |> reset_flashed_energy()
  end
  defp increase_neighbor_energy(grid, []), do: grid
  defp increase_neighbor_energy(grid, positions) do
    positions
    |> Enum.reduce(grid, fn (pos, grid) ->
      {new_grid, flashed} = increase_energy_of_positions(grid, neighbors(pos, grid.dim))
      increase_neighbor_energy(%{new_grid | flashes: new_grid.flashes + Enum.count(flashed)}, flashed)
    end)
  end

  @doc ~S"""
  Increase energy of the given `positions` (a list of `{x, y}` coordinates).

  Returns `{grid, flashed_positions}` where `grid` has been updated,
  and `flashed_positions` is a list of the `{x, y}` coordinates of the
  octopi which flashed.

  ## Examples
      iex> grid = Octopus.Grid.new({{0, 1}, {2, 3}})
      iex> Octopus.Grid.increase_energy_of_positions(grid, Octopus.Grid.positions(grid))
      {%Octopus.Grid{grid: {{1, 2}, {3, 4}}, dim: 2}, []}

      iex> grid = Octopus.Grid.new({{0, 1}, {2, 9}})
      iex> Octopus.Grid.increase_energy_of_positions(grid, Octopus.Grid.positions(grid))
      {%Octopus.Grid{grid: {{1, 2}, {3, 10}}, dim: 2}, [{1, 1}]}
  """
  def increase_energy_of_positions(grid, positions) do
    positions
    |> Enum.reduce({grid, []}, fn (pos, {grid, flashed}) ->
      {grid, new_energy} = increase_energy_of_position(grid, pos)
      if new_energy == 10 do
        {grid, [pos | flashed]}
      else
        {grid, flashed}
      end
    end)
  end

  @doc ~S"""
  Increase energy of the given `{x, y}` coordinate.

  Returns `{grid, new_energy}` where `grid` has been updated,
  and `new_energy` is the new energy level at `{x, y}`.

  ## Examples
      iex> grid = Octopus.Grid.new({{0, 1, 8}, {3, 4, 5}, {6, 7, 2}})
      iex> Octopus.Grid.increase_energy_of_position(grid, {2, 0})
      {%Octopus.Grid{grid: {{0, 1, 9}, {3, 4, 5}, {6, 7, 2}}, dim: 3}, 9}
  """
  def increase_energy_of_position(grid, {x, y}) do
    row = elem(grid.grid, y)
    new_energy = elem(row, x) + 1
    new_row = put_elem(row, x, new_energy)
    {%{grid | grid: put_elem(grid.grid, y, new_row)}, new_energy}
  end

  @doc ~S"""
  Return count of how many octopi just flashed in the previous step.

  ## Examples
      iex> grid = Octopus.Grid.new({{1, 2, 9}, {4, 5, 6}, {7, 8, 3}})
      iex> Octopus.Grid.flashed_count(grid)
      0

      iex> grid = Octopus.Grid.new({{2, 4, 0}, {5, 7, 8}, {8, 9, 4}})
      iex> Octopus.Grid.flashed_count(grid)
      1
  """
  def flashed_count(grid) do
    grid.grid
    |> Tuple.to_list()
    |> Enum.reduce(0, fn (row, count) ->
      zeros =
        row
        |> Tuple.to_list()
        |> Enum.count(fn col -> col == 0 end)
      count + zeros
    end)
  end

  @doc ~S"""
  Did all octopi just flash in the previous step?

  ## Examples
      iex> Octopus.Grid.new({{0, 1}, {2, 3}}) |> Octopus.Grid.synchronized?()
      false

      iex> Octopus.Grid.new({{0, 0}, {0, 0}}) |> Octopus.Grid.synchronized?()
      true
  """
  def synchronized?(grid) do
    flashed_count(grid) == grid.dim * grid.dim
  end
end
