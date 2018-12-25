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
  @spec map(Yard.t(), map()) :: [String.t()]

  def map(yard, opts \\ []) do
    IO.puts(map_label(opts[:label], opts[:label_minute]))
    for y <- y_range(yard),
      do: map_row(yard, y, x_range(yard))
  end

  defp map_label(label, minute) do
    cond do
      label ->
        label
      minute == 0 ->
        "Initial state:"
      true ->
        "After #{minute} minute#{if minute == 1, do: "", else: "s"}:"
    end
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
  Find count of types for surrounding grid cells.

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
  @spec strange_magic(Yard.t(), integer()) :: Yard.t()

  def strange_magic(yard, minutes) do
    1..minutes
    |> Enum.reduce(yard, fn (_m, yard) ->
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

  @doc """
  Find count of types for all cells in the yard.

  ## Examples

      iex> yard = Yard.parse_lines([
      ...>   ".#|#.",
      ...>   "..#..",
      ...>   ".|..|",
      ...>   "..|#.",
      ...>   "#.#||",
      ...> ])
      iex> Yard.count(yard)
      %{open: 13, trees: 6, lumber: 6}
  """
  @spec count(Yard.t()) :: map()

  def count(yard) do
    Enum.reduce(yard.grid, %{open: 0, trees: 0, lumber: 0}, fn ({_pos, content}, counts) ->
      Map.update(counts, content, 1, &(&1 + 1))
    end)
  end

  @doc """
  Find yard checksum.

  ## Examples

      iex> yard = Yard.parse_lines([
      ...>   ".#|#.",
      ...>   "..#..",
      ...>   ".|..|",
      ...>   "..|#.",
      ...>   "#.#||",
      ...> ])
      iex> Yard.checksum(yard)
      627046
  """
  @spec checksum(Yard.t()) :: integer()

  def checksum(yard) do
    Enum.reduce(yard.grid, 0, fn ({{y, x}, content}, acc) ->
      acc + cell_checksum({y, x}, content)
    end)
  end

  defp cell_checksum({y, x}, content) do
    [a, b] = Enum.take(Atom.to_charlist(content), 2)
    (y * a * 101) + (x * b * 11)
  end

  @doc """
  Iterate until yard state repeats any previous state.

  Returns the yard, minute, and states of the last step **before** the
  repeat was observed, along with the checksum of the **repeated** step.
  """
  @spec strange_magic_until_repeat(Yard.t()) :: {Yard.t(), integer(), integer(), tuple()}

  def strange_magic_until_repeat(yard) do
    Stream.iterate(1, &(&1+1))
    |> Enum.reduce_while({yard, MapSet.new(), Map.new()}, fn (m, {yard, check_set, states}) ->
      next_yard = strange_magic(yard, 1)
      next_yard_cs = checksum(next_yard)
      next_yard_ct = count(next_yard)
      if MapSet.member?(check_set, next_yard_cs) do
        # return previous yard/minute/states (last step *before* repeat)
        # plus next yard's checksum (the repeat that caused the halt)
        {:halt, {yard, m-1, next_yard_cs, states}}
      else
        {:cont, {next_yard, MapSet.put(check_set, next_yard_cs), Map.put(states, m, {next_yard_cs, next_yard_ct})}}
      end
    end)
  end

  @doc """
  Return state after Nth iteration, extrapolating from cycle.
  """
  @spec extrapolate_state(list(), integer(), integer(), integer()) :: map()

  def extrapolate_state(states, minute, halt_checksum, target_minute) do
    {min_minute, n_states, cycle} = cycle(states, minute, halt_checksum)
    minutes_left = target_minute - min_minute
    cycle_left = rem(minutes_left, n_states)
    Enum.at(cycle, cycle_left)
    |> elem(1)
  end

  # minute = the last minute before we see a repeat
  # i.e. the last minute of whatever states are stable/cycle/oscillating
  def cycle(states, minute, halt_checksum) do
    cycle =
      minute..0
      |> Enum.reduce_while([], fn (m, cycle) ->
        new_cycle = [{m, elem(states[m], 1)} | cycle]
        cond do
          m < 1 ->
            raise "hit the beginning"  # should not happen
          elem(states[m], 0) == halt_checksum ->
            {:halt, new_cycle}
          true ->
            {:cont, new_cycle}
        end
      end)
      # ...and for once, Elixir list insertion order works in our favor
    min_minute =
      cycle
      |> Enum.min_by(fn ({minute, _states}) -> minute end)
      |> elem(0)
    cycle_0 =
      cycle
      |> Enum.map(fn ({minute, states}) -> {minute-min_minute, states} end)
    {min_minute, Enum.count(cycle_0), cycle_0}
  end
end
