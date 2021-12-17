defmodule Submarine.PriorityQueueTest do
  use ExUnit.Case
  doctest Submarine.PriorityQueue

  import Submarine.PriorityQueue

  def test_queue() do
    queue = new()
    [{{:e, :r}, 5}, {{:h, :i}, 1}, {{:t, :h}, 3}, {{:e, :.}, 8}]
    |> Enum.reduce(queue, fn ({el, pri}, q) ->
      put(q, el, pri)
    end)
  end

  test "basic insertion and removal" do
    queue = test_queue()
    assert peek(queue) == {:h, :i}
    {queue, next} = pop(queue)
    assert next == {:h, :i}
    {queue, next} = pop(queue)
    assert next == {:t, :h}
    {queue, next} = pop(queue)
    assert next == {:e, :r}
    assert !empty?(queue)
    {queue, next} = pop(queue)
    assert next == {:e, :.}
    assert empty?(queue)
  end

  test "priority change" do
    queue = test_queue()
    {queue, next} = pop(queue)
    assert next == {:h, :i}
    queue = update(queue, {:e, :r}, 5, 2)
    {queue, next} = pop(queue)
    assert next == {:e, :r}
    {queue, next} = pop(queue)
    assert next == {:t, :h}
    {queue, next} = pop(queue)
    assert next == {:e, :.}
    assert empty?(queue)
  end

  test "attempted priority update, old not found" do
    queue = test_queue()
    {queue, next} = pop(queue)
    assert next == {:h, :i}
    assert_raise FunctionClauseError, fn -> update(queue, {:h, :i}, 1, 2) end
  end

  test "attempted duplicate priority put" do
    queue = test_queue()
    assert_raise ArgumentError, fn -> put(queue, {:x, :y}, 1) end
  end

  test "attempted duplicate priority update" do
    queue = test_queue()
    # some other entry found at old priority:
    assert_raise ArgumentError, fn -> update(queue, {:e, :.}, 1, 7) end
    # new priority is already in use by something else:
    assert_raise ArgumentError, fn -> update(queue, {:e, :.}, 8, 1) end
  end
end
