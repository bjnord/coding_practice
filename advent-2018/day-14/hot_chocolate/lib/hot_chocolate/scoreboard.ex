defmodule HotChocolate.Scoreboard do
  @moduledoc """
  Documentation for HotChocolate.Scoreboard.

  TODO use @type @spec etc.
  """

  @doc """
  Create a new scoreboard.

  ## Examples

      iex> HotChocolate.Scoreboard.new()
      {0, %{}}

      iex> HotChocolate.Scoreboard.new([3, 7])
      {2, %{0 => 3, 1 => 7}}
  """
  def new(scores \\ []) do
    Enum.reduce(scores, {0, %{}}, fn (score, {count, map}) ->
      HotChocolate.Scoreboard.add({count, map}, score)
    end)
  end

  @doc """
  Add a score to a scoreboard.

  ## Examples

      iex> HotChocolate.Scoreboard.new()
      ...> |> HotChocolate.Scoreboard.add(3)
      ...> |> HotChocolate.Scoreboard.add(7)
      {2, %{0 => 3, 1 => 7}}
  """
  # TODO assert score in 0..9
  #      (then also test new() with bad score)
  def add({count, map}, score) do
    {count + 1, Map.put(map, count, score)}
  end

  @doc """
  Get a score from a scoreboard.

  ## Examples

      iex> sb = HotChocolate.Scoreboard.new([3, 7, 1, 0])
      iex> HotChocolate.Scoreboard.get(sb, 0)
      3
      iex> HotChocolate.Scoreboard.get(sb, 1)
      7
  """
  def get({_count, map}, index) do
    map[index]
  end

  @doc """
  Get a subset of a scoreboard.

  ## Examples

      iex> sb = HotChocolate.Scoreboard.new([3, 7, 1, 0])
      iex> HotChocolate.Scoreboard.slice(sb, 0, 2)
      [3, 7]
      iex> HotChocolate.Scoreboard.slice(sb, -2, 2)
      [1, 0]
      iex> HotChocolate.Scoreboard.slice(sb, 3, 3)
      [0]
      iex> HotChocolate.Scoreboard.slice(sb, -6, 6)
      [3, 7, 1, 0]
  """
  def slice({count, map}, index, length) do
    range =
      cond do
        index < 0 -> count+index..count+index+length-1
        true      -> index..index+length-1
      end
    range
    |> Enum.map(fn (i) -> map[i] end)
    |> Enum.reject(fn (score) -> score == nil end)
  end

  @doc """
  Get number of scores in a scoreboard.

  ## Examples

      iex> HotChocolate.Scoreboard.new()
      ...> |> HotChocolate.Scoreboard.count()
      0

      iex> HotChocolate.Scoreboard.new([3, 7])
      ...> |> HotChocolate.Scoreboard.count()
      2
  """
  def count({count, _map}) do
    count
  end

  @doc """
  Create new scores in a scoreboard.

  This creates new scores from two existing scores:

  - the two scores are retrieved by the indexes passed in
  - if the combined sum is two digits, two new scores are created
    (one for each digit)
  - if the combined sum is only one digit, one new score is created
    (with that digit)

  The new scores are added to the Scoreboard in order.

  ## Examples

      iex> HotChocolate.Scoreboard.new([3, 7])
      ...> |> HotChocolate.Scoreboard.create_scores(0, 1)
      {4, %{0 => 3, 1 => 7, 2 => 1, 3 => 0}}

      iex> HotChocolate.Scoreboard.new([3, 6])
      ...> |> HotChocolate.Scoreboard.create_scores(0, 1)
      {3, %{0 => 3, 1 => 6, 2 => 9}}
  """
  def create_scores({count, map}, index1, index2) do
    sum = map[index1] + map[index2]
    if sum >= 10 do
      HotChocolate.Scoreboard.add({count, map}, div(sum, 10))
      |> HotChocolate.Scoreboard.add(rem(sum, 10))
    else
      HotChocolate.Scoreboard.add({count, map}, sum)
    end
  end

  @doc """
  Get new incremented index (modulo) of a scoreboard.

  ## Examples

      iex> sb = HotChocolate.Scoreboard.new([3, 7, 1, 0])
      iex> HotChocolate.Scoreboard.inc_index(sb, 0, 4)
      0
      iex> HotChocolate.Scoreboard.inc_index(sb, 1, 8)
      1

      iex> sb = HotChocolate.Scoreboard.new([3, 7, 1, 0, 1, 0, 1, 2, 4, 5])
      iex> HotChocolate.Scoreboard.inc_index(sb, 4, 2)
      6
      iex> HotChocolate.Scoreboard.inc_index(sb, 8, 5)
      3
  """
  def inc_index({count, _map}, index, increment) do
    rem(index + increment, count)
  end
end
