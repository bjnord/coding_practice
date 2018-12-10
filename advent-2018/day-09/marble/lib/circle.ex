defmodule Circle do
  @moduledoc """
  Documentation for Circle.
  """

  @doc """
  Create a new circle with only initial marble 0.

  ## Parameters

  - max_size: Maximum size of circle

  ## Returns

  New circle
  """
  def new(max_size) do
    {Deque.new(max_size) |> Deque.appendleft(0), 0}
  end

  @doc """
  Create a new circle with marbles from 0 up through count.
  (Only used for testing, to set up an initial state.)

  ## Parameters

  - max_size: Maximum size of circle
  - count: Number of marbles to insert (after initial 0 marble)

  ## Returns

  New circle
  """
  def new(max_size, count) do
    1..count
    |> Enum.reduce(new(max_size), fn (_n, circle) -> insert(circle) |> elem(0) end)
  end

  @doc """
  Extract list of marbles in circle.
  (Only used for testing, to assert circle state.)

  ## Parameters

  - circle: Current circle

  ## Returns

  List of marbles in circle (head will be current marble)
  """
  def to_list({deque, _latest}) do
    Enum.to_list(deque)
  end

  @doc """
  Return latest marble insertion.
  (Only used for testing, to assert circle state.)

  ## Parameters

  - circle: Current circle

  ## Returns

  Number of latest marble insertion. (Note this may not be in the circle, if 23 marble.)
  """
  def latest({_deque, latest}) do
    latest
  end

  @doc """
  Insert next marble into circle.

  ## Parameters

  - circle: Current circle

  ## Returns

  `{new_circle, score}`: Updated circle plus score from insertion
  """
  # special case: add marble 1 to initial circle
  def insert({deque, 0}) do
    {{Deque.appendleft(deque, 1), 1}, 0}
  end

  # if this is a 23-marble:
  # 1. shift 6 marbles from tail to head
  # 2. remove marble from tail
  # 3. score is (this_marble + removed_marble) in this case
  def insert({deque, latest}) when rem(latest+1, 23) == 0 do
    deque = shift_tail_to_head(deque, 6)
    {tail, deque} = Deque.pop(deque)
    {{deque, latest+1}, (latest+1) + tail}
  end

  # otherwise this is not a 23-marble:
  # 1. shift 2 marbles from head to tail
  # 1. insert new marble to head
  # 1. score is 0 in this case
  def insert({deque, latest}) do
    deque = shift_head_to_tail(deque, 2)
            |> Deque.appendleft(latest+1)
    {{deque, latest+1}, 0}
  end

  defp shift_tail_to_head(deque, count) do
    1..count
    |> Enum.reduce(deque, fn (_n, dq) ->
      {tail, dq} = Deque.pop(dq)
      Deque.appendleft(dq, tail)
    end)
  end

  defp shift_head_to_tail(deque, count) do
    1..count
    |> Enum.reduce(deque, fn (_n, dq) ->
      {head, dq} = Deque.popleft(dq)
      Deque.append(dq, head)
    end)
  end
end
