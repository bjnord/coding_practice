defmodule Galaxy do
  @moduledoc """
  Documentation for `Galaxy`.
  """

  import Galaxy.Parser
  import Snow.CLI
  alias Snow.SnowMath

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    |> Galaxy.path_length()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    |> Galaxy.path_length(1_000_000)
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc ~S"""
  Find the maximum Y and X values for an image.

  ## Parameters

  `positions` - list of positions (`{y, x}` tuples)

  Returns a `{max_y, max_x}` tuple.

  ## Examples
      iex> Galaxy.max([{0, 1}, {0, 4}, {2, 0}])
      {2, 4}
  """
  def max(positions) do
    positions
    |> Enum.reduce({0, 0}, fn {y, x}, {max_y, max_x} ->
      {max(y, max_y), max(x, max_x)}
    end)
  end

  @doc ~S"""
  Find the empty rows and columns for an image.

  ## Parameters

  `positions` - list of positions (`{y, x}` tuples)

  Returns a `{max_y, max_x}` tuple.

  ## Examples
      iex> Galaxy.empties([{0, 1}, {0, 4}, {2, 0}])
      {[1], [2, 3]}
  """
  def empties(positions) do
    {max_y, max_x} = max(positions)
    {nonempty_y, nonempty_x} =
      positions
      |> Enum.reduce({%{}, %{}}, fn {y, x}, {nonempty_y, nonempty_x} ->
        {
          Map.put(nonempty_y, y, true),
          Map.put(nonempty_x, x, true),
        }
      end)
    empty_y =
      0..max_y
      |> Enum.reject(fn y -> nonempty_y[y] end)
    empty_x =
      0..max_x
      |> Enum.reject(fn x -> nonempty_x[x] end)
    {empty_y, empty_x}
  end

  @doc ~S"""
  Expand an image, taking into account empty rows and columns.

  ## Parameters

  `positions` - list of positions (`{y, x}` tuples)
  `exp` - expansion distance (integer)

  Returns a list of expanded positions (`{y, x}` tuples).

  ## Examples
      iex> Galaxy.expand([{0, 1}, {0, 4}, {2, 0}])
      [{0, 1}, {0, 6}, {3, 0}]
  """
  def expand(positions), do: expand(positions, 2)
  def expand(positions, exp) do
    {empty_y, empty_x} = empties(positions)
    positions
    |> Enum.map(fn {y, x} ->
      n_empty_y = Enum.count(empty_y, fn e_y -> e_y < y end)
      n_empty_x = Enum.count(empty_x, fn e_x -> e_x < x end)
      {y + n_empty_y * (exp - 1), x + n_empty_x * (exp - 1)}
    end)
  end

  @doc ~S"""
  Find all pairings of image positions.

  ## Parameters

  `positions` - list of positions (`{y, x}` tuples)

  Returns a list of position pairs (`{{y1, x1}, {y2, x2}}` tuples).

  ## Examples
      iex> Galaxy.pairs([{0, 1}, {0, 6}, {3, 0}])
      [{{0, 1}, {0, 6}},
        {{0, 1}, {3, 0}},
        {{0, 6}, {3, 0}}]
  """
  def pairs([_]), do: []
  def pairs([next_pos | rest]) do
    # OPTIMIZE this is inefficient
    Enum.map(rest, fn pos -> {next_pos, pos} end) ++ pairs(rest)
  end

  @doc ~S"""
  Find the total path length between all pairings of image positions, after
  expanding the image.

  ## Parameters

  `positions` - list of (unexpanded) positions (`{y, x}` tuples)
  `exp` - expansion distance (integer)

  Returns the sum of the path length between all pairings of the expanded
  positions.

  ## Examples
      iex> Galaxy.path_length([{0, 1}, {0, 4}, {2, 0}])
      18
  """
  def path_length(positions), do: path_length(positions, 2)
  def path_length(positions, exp) do
    expand(positions, exp)
    |> pairs()
    |> Enum.map(fn {pos1, pos2} ->
      SnowMath.manhattan(pos1, pos2)
    end)
    |> Enum.sum()
  end
end
