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
    {[0], [], 0}
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
  def insert({[0], [], 0}) do
    {{[1, 0], [], 1}, 0}
  end

  # if this is a 23-marble, but we don't have 7+ marbles in back:
  # 1. move all N back marbles to front (however many there are)
  # 2. move (6-N) marbles from the *bottom* of front to the *top* of front
  # 3. remove another marble from the *bottom* of front (the 7th)
  # 4. score is marble we would have inserted + 7th marble we removed
  def insert({front, back, latest}) when (rem(latest+1, 23) == 0) and (length(back) < 7) do
    {bottom_n, front_r} = Enum.reverse(front)
                          |> Enum.split(7 - length(back))
    {[remove], keep} = Enum.reverse(back ++ bottom_n)
                       |> Enum.split(1)
    {{keep ++ Enum.reverse(front_r), [], latest+1}, (latest+1) + remove}
  end

  # if this is a 23-marble (and we do have 7+ marbles in back):
  # 1. move top 6 back marbles to front
  # 2. remove another top back marble (the 7th)
  # 3. score is marble we would have inserted + 7th marble we removed
  def insert({front, back, latest}) when rem(latest+1, 23) == 0 do
    {top_7, new_back} = Enum.split(back, 7)
    {[remove], keep} = Enum.reverse(top_7) |> Enum.split(1)
    {{keep ++ front, new_back, latest+1}, (latest+1) + remove}
  end

  # if we have 2+ marbles in front:
  # 1. move top 2 front marbles to back
  # 2. insert new marble to top of front
  def insert({[current, between | front], back, latest}) do
    {{[latest+1 | front], [between, current | back], latest+1}, 0}
  end

  # otherwise we have 1 marble in front:
  # 1. move all back marbles to front
  # 2. call self recursively, now that front has 2+ marbles
  def insert({[current], back, latest}) do
    insert({[current | Enum.reverse(back)], [], latest})
  end
end
