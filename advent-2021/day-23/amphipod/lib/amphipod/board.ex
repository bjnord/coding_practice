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

  defstruct n_rooms: 0, hallway_pos: [], player_pos: %{}

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
    player_pos =
      amphipos
      |> Enum.with_index()
      |> Enum.map(fn {{_type, pos}, n} -> {n, pos} end)
      |> Enum.into(%{})
    %Board{
      n_rooms: n_rooms,
      hallway_pos: hallway_positions(n_rooms, min_x, max_x),
      player_pos: player_pos,
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

  @doc ~S"""
  Return current player position on board.

  Raises `KeyError` if the given `player` is not found.
  """
  def player_pos(board, player) do
    pos = board.player_pos[player]
    if pos == nil do
      raise KeyError, "player #{player} not found on board"
    else
      pos
    end
  end

  @doc ~S"""
  Update player position on board.

  Raises `KeyError` if the given `player` is not found.
  """
  def update_player_pos(board, player, pos) do
    %Board{board | player_pos: Map.replace!(board.player_pos, player, pos)}
  end

  @doc ~S"""
  Is the given position occupied by a player?
  """
  def occupied?(board, pos) do
    # FIXME OPTIMIZE maintain a map keyed in the other direction
    player =
      Map.values(board.player_pos)
      |> Enum.find(&(&1 == pos))
    if player, do: true, else: false
  end
end
