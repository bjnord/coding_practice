defmodule Cave do
  @moduledoc """
  Documentation for Cave.
  """

  @enforce_keys [:depth, :target]
  defstruct depth: nil, target: {nil, nil}, erosion: %{}

  @type position() :: {integer(), integer()}
  @type position_range() :: {Range.t(integer()), Range.t(integer())}
  @type t() :: %__MODULE__{
    depth: integer(),
    target: position(),
    erosion: map()
  }

  @doc """
  Construct a new cave.
  """
  @spec new(integer(), position()) :: Cave.t()
  def new(depth, {y, x}) when is_integer(depth) and is_integer(y) and is_integer(x) do
    %Cave{depth: depth, target: {y, x}, erosion: %{}}
  end

  @doc """
  Compute geologic index at a position.

  ## Example

      iex> cave = Cave.new(510, {10, 10})
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
  @spec geologic_index(Cave.t(), position()) :: integer()
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
      erosion_level(cave, {y-1, x}) * erosion_level(cave, {y, x-1})
    end
  end

  @doc """
  Compute erosion level at a position.

  ## Example

      iex> cave = Cave.new(510, {10, 10})
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
  @spec erosion_level(Cave.t(), position()) :: integer()
  def erosion_level(cave, {y, x}) do
    if Map.has_key?(cave.erosion, {y, x}) do
      Map.get(cave.erosion, {y, x})
    else
      rem(geologic_index(cave, {y, x}) + cave.depth, 20183)
    end
  end

  @doc """
  Get region type at a position.

  ## Example

      iex> cave = Cave.new(510, {10, 10})
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
  @spec region_type(Cave.t(), position()) :: atom()
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

      iex> cave = Cave.new(510, {10, 10})
      iex> Cave.risk_level(cave, {0..10, 0..10})
      114
  """
  @spec risk_level(Cave.t(), position_range()) :: integer()
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
  @spec risk_level(Cave.t(), position()) :: integer()
  def risk_level(cave, {y, x}) when is_integer(y) and is_integer(x) do
    rem(erosion_level(cave, {y, x}), 3)
  end

  @doc """
  Return range from mouth to target (rectangle).

  ## Example

      iex> cave = Cave.new(100, {7, 9})
      iex> Cave.target_range(cave)
      {0..7, 0..9}
  """
  @spec target_range(Cave.t()) :: position_range()
  def target_range(cave) do
    {target_y, target_x} = cave.target
    {0..target_y, 0..target_x}
  end

  @doc """
  Precalculate erosion for a cave.

  Returns the updated cave, with cached erosion levels.

  ## Example

      iex> cave = Cave.new(21, {3, 3})
      iex> Cave.erosion_level(cave, {1, 1})
      9485
      iex> fast_cave = Cave.cache_erosion(cave, {0..3, 0..3})
      iex> Cave.erosion_level(fast_cave, {1, 1})
      9485
      iex> Enum.count(fast_cave.erosion)
      16
  """
  # TODO OPTIMIZE can this be parallelized?
  @spec cache_erosion(Cave.t(), position_range()) :: Cave.t()
  def cache_erosion(cave, {range_y, range_x}) do
    ###
    # we want reduce here, so {y, x} can take advantage of cached {y-1, x}
    # etc. as we go
    Enum.reduce(range_y, cave, fn (y, cave) ->
      Enum.reduce(range_x, cave, fn (x, cave) ->
        if Map.has_key?(cave.erosion, {y, x}) do
          cave
        else
          %{cave | erosion: Map.put(cave.erosion, {y, x}, erosion_level(cave, {y, x}))}
        end
      end)
    end)
  end

  @doc """
  Generate printable map of a cave.
  """
  @spec map(Cave.t(), position_range()) :: [String.t()]
  def map(cave, {y_range, x_range}) do
    for y <- y_range,
      do: map_row(cave, y, x_range)
  end

  # returns string
  defp map_row(cave, y, x_range) do
    row =
      for x <- x_range,
        do: map_position(cave, {y, x})
    row
    |> to_string()
  end

  # returns charlist
  @spec map_position(Cave.t(), position()) :: integer()
  defp map_position(_cave, position) when position == {0, 0} do
    ?M
  end
  defp map_position(cave, position) do
    rtype = region_type(cave, position)
    cond do
      cave.target == position -> ?T
      rtype == :rocky -> ?.
      rtype == :wet -> ?=
      rtype == :narrow -> ?|
    end
  end
end
