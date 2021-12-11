defmodule Octopus.Grid do
  @moduledoc """
  Grid structure for `Octopus`.
  """

  defstruct dim: 0, grid: {}, flashes: 0

  @doc ~S"""
  Construct a new grid from `input`.

  ## Examples
      iex> Octopus.Grid.new("01\n23\n")
      %Octopus.Grid{dim: 2, grid: {{0, 1}, {2, 3}}, flashes: 0}
  """
  def new(input) do
    grid = parse(input)
    %Octopus.Grid{
      grid: grid,
      dim: tuple_size(grid),
    }
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
    |> Enum.map(fn d -> d - ?0 end)
    |> List.to_tuple()
  end

  @doc ~S"""
  Returns count of flashes seen on the given `grid`.

  ## Examples
      iex> grid = Octopus.Grid.new("93\n39\n") |> Octopus.Grid.increase_energy()
      iex> Octopus.Grid.n_flashes(grid)
      2
  """
  def n_flashes(grid), do: grid.flashes

  @doc false
  # Returns a list of all `{x, y}` positions for the given `grid`.
  defp positions(grid) do
    for y <- 0..grid.dim-1 do
      for x <- 0..grid.dim-1 do
        {x, y}
      end
    end
    |> List.flatten()
  end

  @doc false
  # Returns a list of all neighboring positions to `{x0, y0}`
  # for a grid of the given `dim`.
  defp neighbors({x0, y0}, dim) do
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

  @doc false
  # Reset energy level to 0 for any `grid` position that flashed
  # (_i.e._ is above 9).
  defp reset_flashed_energy(grid) do
    positions(grid)
    |> Enum.reduce(grid, fn (pos, grid) ->
      reset_energy_of_position(grid, pos)
    end)
  end

  @doc false
  # Reset energy of the given `{x, y}` coordinate, if it's above 9.
  # Returns updated `grid`.
  defp reset_energy_of_position(grid, {x, y}) do
    row = elem(grid.grid, y)
    if elem(row, x) > 9 do
      new_row = put_elem(row, x, 0)
      %{grid | grid: put_elem(grid.grid, y, new_row)}
    else
      grid
    end
  end

  @doc ~S"""
  Do one increase-energy step.

  Returns the updated `grid`.
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

  @doc false
  # Increase energy of the given `positions` (a list of `{x, y}` coords).
  #
  # Returns `{grid, flashed_positions}` where `grid` has been updated,
  # and `flashed_positions` is a list of the `{x, y}` coordinates of the
  # octopi which flashed.
  defp increase_energy_of_positions(grid, positions) do
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

  @doc false
  # Increase energy of the given `{x, y}` coordinate.
  #
  # Returns `{grid, new_energy}` where `grid` has been updated,
  # and `new_energy` is the new energy level at `{x, y}`.
  defp increase_energy_of_position(grid, {x, y}) do
    row = elem(grid.grid, y)
    new_energy = elem(row, x) + 1
    new_row = put_elem(row, x, new_energy)
    {%{grid | grid: put_elem(grid.grid, y, new_row)}, new_energy}
  end

  @doc false
  # Return count of how many octopi just flashed in the previous step.
  defp flashed_count(grid) do
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
      iex> Octopus.Grid.new("01\n23\n") |> Octopus.Grid.synchronized?()
      false

      iex> Octopus.Grid.new("00\n00\n") |> Octopus.Grid.synchronized?()
      true
  """
  def synchronized?(grid) do
    flashed_count(grid) == grid.dim * grid.dim
  end
end