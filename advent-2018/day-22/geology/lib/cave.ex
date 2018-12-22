defmodule Cave do
  @moduledoc """
  Documentation for Cave.
  """

  defstruct depth: 2, target: {1, 1}

  @doc """
  Compute geologic index at a position.

  ## Example

      iex> cave = %Cave{depth: 510, target: {10, 10}}
      iex> Cave.geologic_index(cave, {0, 0})
      0
      iex> Cave.geologic_index(cave, {0, 1})
      16807
      iex> Cave.geologic_index(cave, {1, 0})
      48271
      iex> Cave.geologic_index(cave, {1, 1})
      145722555
      iex> Cave.geologic_index(cave, {10, 10})
      0
  """
  def geologic_index(_cave, {y, x}) when {y, x} == {0, 0} do
    0
  end
  def geologic_index(_cave, {y, x}) when (y == 0) do
    x * 16807
  end
  def geologic_index(_cave, {y, x}) when (x == 0) do
    y * 48271
  end
  def geologic_index(cave, {y, x}) do
    if {y, x} == cave.target do
      0
    else
      # TODO OPTIMIZE can this be parallelized?
      erosion_level(cave, {y-1, x}) * erosion_level(cave, {y, x-1})
    end
  end

  @doc """
  Compute erosion level at a position.

  ## Example

      iex> cave = %Cave{depth: 510, target: {10, 10}}
      iex> Cave.erosion_level(cave, {0, 0})
      510
      iex> Cave.erosion_level(cave, {0, 1})
      17317
      iex> Cave.erosion_level(cave, {1, 0})
      8415
      iex> Cave.erosion_level(cave, {1, 1})
      1805
      iex> Cave.erosion_level(cave, {10, 10})
      510
  """
  def erosion_level(cave, {y, x}) do
    rem(geologic_index(cave, {y, x}) + cave.depth, 20183)
  end

  @doc """
  Get region type at a position.

  ## Example

      iex> cave = %Cave{depth: 510, target: {10, 10}}
      iex> Cave.region_type(cave, {0, 0})
      :rocky
      iex> Cave.region_type(cave, {0, 1})
      :wet
      iex> Cave.region_type(cave, {1, 0})
      :rocky
      iex> Cave.region_type(cave, {1, 1})
      :narrow
      iex> Cave.region_type(cave, {10, 10})
      :rocky
  """
  def region_type(cave, {y, x}) do
    case risk_level(cave, {y, x}) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end

  @doc """
  Compute total risk level.

  ## Example

      iex> cave = %Cave{depth: 510, target: {10, 10}}
      iex> Cave.risk_level(cave, {0..10, 0..10})
      114
  """
  def risk_level(cave, {y_range, x_range}) when is_map(y_range) and is_map(x_range) do
    squares =
      for y <- y_range,
        x <- x_range,
        do: risk_level(cave, {y, x})
    Enum.sum(squares)
  end

  @doc """
  Compute risk level at a position.
  """
  def risk_level(cave, {y, x}) when is_integer(y) and is_integer(x) do
    rem(erosion_level(cave, {y, x}), 3)
  end

  @doc """
  Return range from mouth to target (rectangle).

  ## Example

      iex> cave = %Cave{depth: 100, target: {7, 9}}
      iex> Cave.target_range(cave)
      {0..7, 0..9}
  """
  def target_range(cave) do
    {target_y, target_x} = cave.target
    {0..target_y, 0..target_x}
  end
end
