defmodule Circle do
  @moduledoc """
  Documentation for Circle.
  """

  @doc """
  Create a new circle with only initial marble 0.

  ## Returns

  New circle
  """
  def new do
    {[0], []}
  end

  @doc """
  Create a new circle with marbles from 0 up through count.
  (Only used for testing, to set up an initial state.)

  ## Parameters

  - count: Number of marbles to insert (after initial 0 marble)

  ## Returns

  New circle
  """
  def new(count) do
    1..count
    |> Enum.reduce(new(), fn (_n, circle) -> insert(circle) |> elem(0) end)
  end

  @doc """
  Insert next marble into circle.
  (See `README.md` for design details.)

  ## Parameters

  - circle: Current circle

  ## Returns

  `{new_circle, score}`: Updated circle plus score from insertion
  """
  # special case: add marble 1 to initial circle
  def insert({[0], []}) do
    {{[1, 0], []}, 0}
  end

  # if this is a 23-marble:
  # 1. move top 6 marbles from back to front
  # 2. remove next top marble (7th) from back
  # 3. score is marble we would have inserted + 7th marble we removed
  def insert({[current | front], back}) when rem(current, 23) == 22 do
    {top_7, new_back} = Enum.split(back, 7)
    {[remove], keep} = Enum.reverse(top_7) |> Enum.split(1)
    {{keep ++ [current | front], new_back}, (current+1) + remove}
  end

  # if we have 2 marbles in front:
  # 1. move top 2 marbles from front to back
  # 2. add new marble to front
  def insert({[current, between | front], back}) do
    {{[current+1 | front], [between, current | back]}, 0}
  end

  # otherwise we only have 1 marble in front:
  # 1. move all back marbles to front
  # 2. call self recursively
  def insert({[current], back}) do
    insert({[current | Enum.reverse(back)], []})
  end
end
