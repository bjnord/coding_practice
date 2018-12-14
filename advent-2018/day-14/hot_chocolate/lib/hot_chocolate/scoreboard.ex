defmodule HotChocolate.Scoreboard do
  @moduledoc """
  Documentation for HotChocolate.Scoreboard.

  FIXME the yellow banner for iex h comes out e.g. "def get(arg, index)"
        (1st arg is the board tuple); can "arg" show up as "scoreboard"?
  """

  @type score() :: 0..9
  @type scoreboard() :: {count :: non_neg_integer(), scores :: map()}

  @doc """
  Create a new scoreboard.

  ## Examples

      iex> HotChocolate.Scoreboard.new()
      {0, %{}}

      iex> HotChocolate.Scoreboard.new([3, 7])
      {2, %{0 => 3, 1 => 7}}
  """
  @spec new([score()]) :: scoreboard()
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

      iex> HotChocolate.Scoreboard.new()
      ...> |> HotChocolate.Scoreboard.add(10)
      ** (HotChocolate.InvalidScore) score 10 outside range 0..9
  """
  @spec add(scoreboard(), score()) :: scoreboard()
  def add({count, map}, score) when score in 0..9 do
    {count + 1, Map.put(map, count, score)}
  end
  def add({_count, _map}, score) do
    raise HotChocolate.InvalidScore, score
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
  @spec get(scoreboard(), non_neg_integer()) :: score()
  def get({_count, map}, index) do
    map[index]
  end

  @doc """
  Get a subset of a scoreboard's scores.

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
  @spec slice(scoreboard(), integer(), non_neg_integer()) :: [score()]
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
  @spec count(scoreboard()) :: non_neg_integer()
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
  @spec create_scores(scoreboard(), non_neg_integer(), non_neg_integer()) :: scoreboard()
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
  @spec inc_index(scoreboard(), non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def inc_index({count, _map}, index, increment) do
    rem(index + increment, count)
  end
end
