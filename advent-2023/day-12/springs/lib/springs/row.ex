defmodule Springs.Row do
  @moduledoc """
  Row structure and functions for `Springs`.
  """

  defstruct springs: [], groups: []

  @doc ~S"""
  Determine the number of spring arrangements in a `Row` that satisfies
  the groups constraint.

  ## Parameters

  - `row` - the `Row`.

  Returns the number of arrangements (integer).

  ## Examples
      iex> row = %Springs.Row{
      ...>   springs: ['????', '#', '#'],
      ...>   groups: [4, 1, 1],
      ...> }
      iex> arrangements(row)
      1
  """
  def arrangements(row) do
    # neither of these lists are long, even in the puzzle input; but
    # TODO we could move the length calculation to the parser
    n_springs = Enum.count(row.springs)
    n_groups = Enum.count(row.groups)
    n_arrangements(row, n_springs, n_groups)
  end

  defp n_arrangements(row, n_springs, n_groups) when n_springs == n_groups do
    [row.springs, row.groups]
    |> Enum.zip()
    |> Enum.map(fn {spring, group} -> permutations(spring, group) end)
    |> Enum.product()
  end

  @doc ~S"""
  Determine the number of permutations of a spring cluster that satisfies
  the count constraint.

  All permutations must have contiguous springs:
  - valid: `##...`, `.##..`, `...##`
  - invalid: `.#.#.`

  ## Parameters

  - `springs` - the spring cluster (charlist)
  - `count` - the number of springs (integer)

  Returns the number of permutations (integer).

  ## Examples
      iex> permutations('?#???', 5)
      1
      iex> permutations('?????', 2)
      4
      iex> permutations('?#???', 2)
      2
  """
  def permutations(springs, count) do
    # OPTIMIZE could do a slightly faster one-pass count here
    n_springs = Enum.count(springs)
    # TODO decide if calculating `n_unknowns` is worth it
    n_unknowns = Enum.count(springs, fn s -> s == ?? end)
    n_permutations(springs, n_springs, n_unknowns, count)
  end

  # ('?#???', 5) = '#####'
  defp n_permutations(_springs, n_springs, _n_unknowns, count) when n_springs == count, do: 1

  # ('?????', 2) = '...##', '..##.', '.##..', '##...'
  defp n_permutations(_springs, n_springs, n_unknowns, count) when n_springs == n_unknowns do
    (n_springs - count) + 1
  end

  # ('????', 5) is impossible
  defp n_permutations(_springs, n_springs, _n_unknowns, count) when n_springs < count, do: 0

  # ('?#???', 2) = '.##..', '##...'
  defp n_permutations(springs, n_springs, _n_unknowns, count) when n_springs > count do
    slide(n_springs, count)
    |> Enum.count(fn slide -> !invalid_springs?(springs, slide) end)
  end

  # (5, 2) = '...##', '..##.', '.##..', '##...'
  defp slide(n_springs, count) do
    0..(n_springs - count)
    |> Enum.map(fn offset ->
      # FIXME could this be just a `reduce()` using `n_springs` range?
      Stream.cycle([true])
      |> Enum.reduce_while({0, [], offset, count}, fn _, {len, springs, off, ct} ->
        cond do
          off > 0 ->
            {:cont, {len + 1, [?. | springs], off - 1, ct}}
          ct > 0 ->
            {:cont, {len + 1, [?# | springs], 0, ct - 1}}
          len < n_springs ->
            {:cont, {len + 1, [?. | springs], 0, 0}}
          true ->
            {:halt, springs}
        end
      end)
    end)
  end

  defp invalid_springs?(springs, slide) do
    [springs, slide]
    |> Enum.zip()
    |> Enum.any?(fn {a, b} -> (a == ?#) && (b == ?.) end)
  end
end
