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
    0  # TODO
  end
end
