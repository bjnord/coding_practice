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
      ...>   clusters: [{'??????##', 6, 2}],
      ...>   counts: [1, 1, 3],
      ...> }
      iex> arrangements(row)
      3
  """
  def arrangements(_row) do
    0  # TODO
  end

  def pairings(row) do
    balanced_counts(row, Enum.count(row.clusters), Enum.count(row.counts))
    |> Enum.map(&({&1, row.clusters}))
    |> Enum.filter(&possible_pairing?/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  # `{ [[1], [1, 1]] , [{'?', 1, 0}, {'###', 0, 3}] }`
  defp possible_pairing?({count_lists, clusters}) do
    Enum.zip(count_lists, clusters)
    |> Enum.all?(&(possible?(&1)))
  end

  # `{ [1, 1] , {'###', 0, 3} }`
  defp possible?({counts, {_pattern, n_q, n_s}}) do
    count =
      counts
      |> Enum.intersperse(1)
      |> Enum.sum()
    ((count >= n_s) && (count <= (n_q + n_s)))
  end

  defp balanced_counts(row, n_clusters, n_counts) when n_clusters == n_counts do
    row.counts
    |> Enum.map(&([&1]))
    |> then(&([&1]))
  end

  defp balanced_counts(row, 1, _n_counts) do
    [[row.counts]]
  end

  # "all the places we can insert dividers into a list of N counts to
  # form N clusters"
  defp balanced_counts(row, n_clusters, n_counts) when n_clusters < n_counts do
    # TODO
    row.counts
    |> Enum.map(&([&1 + 1_000]))
    |> then(&([&1]))
  end

  # "all the places we can insert extra 0 counts into a list of N counts
  # to form N clusters"
  defp balanced_counts(row, n_clusters, n_counts) when n_clusters > n_counts do
    count_lists =
      row.counts
      |> Enum.map(&([&1]))
    0..n_counts  # [sic]
    |> Combination.combine(n_clusters - n_counts)
    |> Enum.map(fn insert_indexes ->
      insert_zeroes(count_lists, insert_indexes)
    end)
  end

  defp insert_zeroes(count_lists, insert_indexes) do
    insert_indexes
    |> Enum.sort(&(&1 >= &2))
    |> Enum.reduce(count_lists, fn index, count_lists ->
      List.insert_at(count_lists, index, [0])
    end)
  end
end
