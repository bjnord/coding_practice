# original from <https://rosettacode.org/wiki/Priority_queue#Elixir>
# and hacked up for the 2021 Day 15 implementation of Dijkstra's algorithm

defmodule Submarine.PriorityQueue do
  @moduledoc """
  ## Important Notes

  1. `priority` values **must be unique**
     (they are used as keys in the underlying data structure)
  1. **smallest** `priority` value = **highest** priority
     (_i.e._ will be the first thing retrieved by `pop()`)
  """

  @doc """
  Construct new empty `PriorityQueue`.
  """
  def new(), do: :gb_trees.empty

  @doc """
  Add new `element` with `priority`. This assumes both `element` and
  `priority` are new values; the call will fail if an existing element
  uses `priority` (priorities must be unique).
  """
  def put(queue, element, priority) do
    # priority = key, element = value
    if :gb_trees.is_defined(priority, queue) do
      raise ArgumentError, "duplicate priority #{priority}"
    end
    :gb_trees.enter(priority, element, queue)
  end

  @doc """
  Update the priority of `element` to `new_priority`. This assumes
  `element` already exists at `old_priority`; the call will fail if:
  1. the existing `element` + `old_priority` is not found
  1. the `new_priority` is already being used by a different element
     (priorities must be unique)
  """
  def update(queue, element, old_priority, new_priority) do
    # *_priority = key, element = value
    {value, queue} = :gb_trees.take(old_priority, queue)
    if value != element do
      raise ArgumentError, "duplicate old_priority #{old_priority}"
    end
    put(queue, element, new_priority)
  end

  @doc """
  Return the highest-priority element (without affecting `queue`).
  """
  def peek(queue) do
    {_priority, element, _queue} = :gb_trees.take_smallest(queue)
    element
  end

  @doc """
  Remove and return the highest-priority element (along with the
  updated `queue`).
  """
  def pop(queue) do
    {_priority, element, queue} = :gb_trees.take_smallest(queue)
    {queue, element}
  end

  @doc """
  Is `queue` empty?
  """
  def empty?(queue) do
    :gb_trees.is_empty(queue)
  end
end
