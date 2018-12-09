# Puzzle: https://adventofcode.com/2018/day/8
# Stream: https://www.twitch.tv/videos/346803810
defmodule Day8 do
  @type metadata :: integer
  @type tree :: {[tree], [metadata]}

  @doc """
  Hello world.

  ## Examples

      iex> Day8.tree_from_string("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      { # A
       [{ # B
         [],
         [10, 11, 12]
        },
        { # C
         [{ # D
           [],
           [99]
          }],
         [2]
        }],
       [1, 1, 2]
      }

  """
  @spec tree_from_string(String.t()) :: tree()
  def tree_from_string(string) when is_binary(string) do
    {root, []} =
      string
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> build_node()

    root
  end

  defp build_node([number_of_children, number_of_metadata | rest]) do
    {children, rest} = children(number_of_children, rest, [])
    {metadata, rest} = Enum.split(rest, number_of_metadata)
    {{children, metadata}, rest}
  end

  defp children(0, rest, acc) do
    {Enum.reverse(acc), rest}
  end

  defp children(count, rest, acc) do
    {node, rest} = build_node(rest)
    children(count - 1, rest, [node | acc])
  end

  @doc """
  Sums all metadata in a tree.

      iex> tree = Day8.tree_from_string("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      iex> Day8.sum_metadata(tree)
      138

  """
  @spec sum_metadata(tree) :: integer()
  def sum_metadata(tree) do
    sum_metadata(tree, 0)
  end

  defp sum_metadata({children, metadata}, acc) do
    sum_children = Enum.reduce(children, 0, &sum_metadata/2)
    sum_children + Enum.sum(metadata) + acc
  end

  @doc """
  Computes the indexed sum.

      iex> tree = Day8.tree_from_string("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      iex> Day8.indexed_sum(tree)
      66

  """
  def indexed_sum({[], metadata}) do
    Enum.sum(metadata)
  end

  def indexed_sum({children, metadata}) do
    indexed_sums = Enum.map(children, &indexed_sum/1)
    Enum.reduce(metadata, 0, &Enum.at(indexed_sums, &1 - 1, 0) + &2)
  end

  @doc """
  Not required for today's challenge but here is how we could
  build an enumerable that emits the metadata elements one by one.
  """
  def metadata_traverser({children, metadata}) do
    Stream.unfold({metadata, children}, fn
      {[head], [{grand_children, metadata} | children]}  ->
        {head, {metadata, grand_children ++ children}}

      {[head | tail], children} ->
        {head, {tail, children}}

      {[], []} ->
        nil
    end)
  end
end
