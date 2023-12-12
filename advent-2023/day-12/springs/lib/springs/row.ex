defmodule Springs.Row do
  @moduledoc """
  Row structure and functions for `Springs`.
  """

  defstruct clusters: [], counts: []

  @doc ~S"""
  Find the number of unique spring arrangements in a `Row` that satisfy
  the clusters and counts constraints.

  ## Parameters

  - `row` - the `Row`.

  Returns the number of arrangements (integer).

  ## Examples
      iex> row = %Springs.Row{
      ...>   clusters: ['????', '#', '#'],
      ...>   counts: [4, 1, 1],
      ...> }
      iex> arrangements(row)
      1
      iex> row3 = %Springs.Row{
      ...>   clusters: ['??????##'],
      ...>   counts: [1, 1, 3],
      ...> }
      iex> arrangements(row3)
      3
  """
  def arrangements(row) do
    # neither of these lists are long, even in the puzzle input; but
    # TODO we could move the length calculation to the parser
    n_clusters = Enum.count(row.clusters)
    n_counts = Enum.count(row.counts)
    arrangements(row, n_clusters, n_counts)
  end

  # TODO this special case can now go away?
  defp arrangements(row, n_clusters, n_counts) when n_clusters == n_counts do
    [row.clusters, row.counts]
    |> Enum.zip()
    |> Enum.map(fn {springs, count} ->
      permutations(springs, count)
      |> Enum.count()
    end)
    |> Enum.product()
  end

  # TODO this special case can now go away?
  defp arrangements(row, n_clusters, n_counts) when (n_clusters == 1) and (n_clusters < n_counts) do
    arrangements_1(List.first(row.clusters), row.counts, 0)
    |> Enum.count()
  end

  defp arrangements(row, n_clusters, n_counts) when n_clusters < n_counts do
    # N ways to divide the counts between the clusters
    # (we find the combinations of "gaps" between the groups)
    combinations =
      1..(n_counts - 1)
      |> Combination.combine(n_clusters - 1)
    count_groups =
      combinations
      |> Enum.map(fn combination ->
        [n_counts | combination]
        |> Enum.sort()
        |> Enum.reduce({[], row.counts, 0}, fn division, {acc, counts, i} ->
          # TODO is there a better way to divide a list in half?
          takes = Enum.take(counts, division - i)
          rest = Enum.drop(counts, division - i)
          {[takes | acc], rest, division}
        end)
        |> elem(0)
        |> Enum.reverse()
      end)
    [row.clusters, count_groups]
    |> Enum.zip()
    |> Enum.map(fn {cluster, counts} ->
      arrangements_1(cluster, counts, 0)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp arrangements_1(springs, [count], level) do
    springs
    |> permutations(count)
  end

  defp arrangements_1(springs, [count | counts], level) do
    n_springs = Enum.count(springs)
    breakpoints(springs, n_springs)
    |> Enum.reduce([], fn {_, i}, acc ->
      # TODO is there a better way to divide a list in half?
      left = Enum.take(springs, i)
             |> permutations(count)
      right = Enum.drop(springs, i+1)
             |> arrangements_1(counts, level + 1)
      combos =
        for a <- left, b <- right, do: a ++ [?. | b]
      acc ++ combos
    end)
    |> Enum.uniq()
  end

  defp breakpoints(springs, n_springs) do
    springs
    |> Enum.with_index()
    |> Enum.reject(fn {ch, i} ->
      (i == 0) || (i == n_springs - 1) || (ch == ?#)
    end)
  end

  @doc ~S"""
  Find the permutations of a spring cluster that satisfy the cluster
  and count constraints.

  All permutations must have contiguous springs:
  - valid: `##...`, `.##..`, `...##`
  - invalid: `.#.#.`

  ## Parameters

  - `springs` - the spring cluster (charlist)
  - `count` - the number of springs (integer)

  Returns the possible permutations (list of charlist).

  ## Examples
      iex> permutations('?#???', 5)
      ['#####']
      iex> permutations('?????', 2)
      ['...##', '..##.', '.##..', '##...']
      iex> permutations('?#???', 2)
      ['.##..', '##...']
  """
  def permutations(springs, count) do
    n_springs = Enum.count(springs)
    permutations(springs, n_springs, count)
  end

  # ('?#???', 5) = ['#####']
  defp permutations(_springs, n_springs, count) when n_springs == count do
    [List.duplicate(?#, count)]
  end

  # ('????', 5) is impossible
  defp permutations(_springs, n_springs, count) when n_springs < count, do: []

  # ('?#???', 2) = ['.##..', '##...']
  defp permutations(springs, n_springs, count) when n_springs > count do
    slide(n_springs, count)
    |> Enum.filter(fn slide -> !invalid_springs?(springs, slide) end)
  end

  # (5, 2) = ['...##', '..##.', '.##..', '##...']
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
