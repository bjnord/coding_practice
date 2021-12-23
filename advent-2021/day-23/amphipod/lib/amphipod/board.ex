defmodule Amphipod.Board do
  @moduledoc """
  Game board for `Amphipod`.

  Responsibilities **limited to**:
  1. Geometry of the board (hall length, # of rooms)
  1. Tracking the `{x, y}` positions of players `0..n-1`
  1. Calculating legal to-hall and to-room moves for a player
     1. checking if position is occupied by another player
     1. checking if path to position is blocked
     1. returning move _distance_ for each

  This module knows nothing about:
  1. Player types (they're all just pawns)
  1. Whether a move is disallowed by game rules (beyond what is checked above)
  1. Whether a move is strategically desirable
  1. The _cost_ of a move
  """

  alias Amphipod.Board

  defstruct n_rooms: 0, hallway_pos: []

  @doc ~S"""
  Construct new game board.
  """
  def new(amphipos) do
    n_rooms =
      amphipos
      |> Enum.map(fn {type, {_x, _y}} -> type end)
      |> Enum.max()
      |> (&(&1 + 1)).()
    {min_x, max_x} =
      amphipos
      |> Enum.map(fn {_type, {x, _y}} -> x end)
      |> Enum.min_max()
    %Board{
      n_rooms: n_rooms,
      hallway_pos: hallway_positions(n_rooms, min_x, max_x),
    }
  end

  defp hallway_positions(n_rooms, min_x, max_x) do
    leftcul_x = for x <- 1..min_x-1, do: x
    n_cul = Enum.count(leftcul_x)
    rightcul_x = for x <- max_x+1..max_x+n_cul, do: x
    middle_x = for r <- 1..n_rooms-1, do: (r-1)*2+min_x+1
    leftcul_x ++ middle_x ++ rightcul_x
    |> Enum.map(&({&1, 2}))
  end
end
