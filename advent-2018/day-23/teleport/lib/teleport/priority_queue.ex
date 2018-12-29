defmodule Teleport.PriorityQueue do
  @moduledoc """
  Priority queue for `Teleport`.
  """

  @enforce_keys [:entries, :count]
  defstruct entries: [], count: 0

  @type t() :: %__MODULE__{
    entries: list(),
    count: integer(),
  }

  @doc """
  Construct a new pqueue.

  Assumes the initial elements are sorted!
  """
  def new(entries) do
    %Teleport.PriorityQueue{entries: entries, count: Enum.count(entries)}
  end

  @doc """
  Return size of pqueue.
  """
  def count(pqueue) do
    pqueue.count
  end

  @doc """
  Return keys of pqueue entries.
  """
  def keys(pqueue) do
    pqueue.entries
    |> Enum.map(&(elem(&1, 0)))
  end

  @doc """
  Remove and return top entry of pqueue.

  ## Returns

  `{updated_pqueue, top_entry}` (`top_entry==nil` if pqueue is empty)
  """
  def pop(pqueue) do
    if pqueue.count > 0 do
      [top_entry | entries] = pqueue.entries
      updated_pqueue =
        %Teleport.PriorityQueue{entries: entries, count: pqueue.count - 1}
      {updated_pqueue, top_entry}
    else
      {pqueue, nil}
    end
  end

  @doc """
  Add entries to priority queue.

  (Does not assume the new elements are sorted.)
  """
  def add(pqueue, u_new_entries) do
    new_entries = Enum.sort_by(u_new_entries, &(elem(&1, 0)))
    new_count = Enum.count(new_entries)
    {q_head_r, q_tail} =
      Stream.cycle([true])
      |> Enum.reduce_while({[], pqueue.entries, new_entries}, fn (_t, {q_head_r, q_tail, left}) ->
        cond do
          left == [] ->
            {:halt, {q_head_r, q_tail}}
          q_tail == [] ->
            {:halt, {q_head_r, left}}
          ###
          # if everything left belongs further down the tail,
          # just move top entry of tail over to reversed-head
          List.first(left) > List.first(q_tail) ->
            [q_tail_h | q_tail_t] = q_tail
            {:cont, {[q_tail_h | q_head_r], q_tail_t, left}}
          ###
          # otherwise, top entry of left goes before the tail;
          # move it to reversed-head
          true ->
            [left_h | left_t] = left
            {:cont, {[left_h | q_head_r], q_tail, left_t}}
        end
      end)
    ###
    # finally, flip all the reversed-head entries to the top of tail
    entries =
      q_head_r
      |> Enum.reduce(q_tail, fn (entry, queue) -> [entry | queue] end)
    %Teleport.PriorityQueue{entries: entries, count: pqueue.count + new_count}
  end
end
