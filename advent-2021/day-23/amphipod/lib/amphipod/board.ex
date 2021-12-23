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

  defstruct n_rooms: 0, hall_pos: [], player_pos: %{}

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
      hall_pos: hall_positions(n_rooms, min_x, max_x),
      player_pos: player_pos,
    }
  end

  defp hall_positions(n_rooms, min_x, max_x) do
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
    if occupied_by(board, pos), do: true, else: false
  end

  defp occupied_by(board, pos) do
    # FIXME OPTIMIZE maintain a map keyed in the other direction
    Enum.map(board.player_pos, &(&1))
    |> Enum.find_value(fn {k, v} -> if v == pos, do: k, else: nil end)
  end

  @doc ~S"""
  Return list of hall positions currently accessible to the given `player`.

  Each return item is `{pos, dist}`.
  """
  def hall_positions_accessible_to(board, _player) do
    # FIXME needs to check if path is blocked
    board.hall_pos
    |> Enum.reject(&(occupied?(board, &1)))
    |> Enum.map(&({&1, 8}))  # FIXME 8 -> Manhattan distance
  end

  @doc ~S"""
  Return list of `room` positions currently accessible to the given `player`.

  If a `neighbor_is_ok` callback is provided,
  - it will **only** be called on **occupied** neighboring spaces,
  - with two parameters, `player` and `neighbor_player`
  If the callback returns
  - `false`, the potential `room` position is filtered out
  - `true`, the potential `room` position is kept

  Each return item is `{pos, dist}`.
  """
  def room_positions_accessible_to(board, player, room, neighbor_is_ok \\ nil) do
    # FIXME needs to check if path is blocked
    room_pos(board, room)
    |> Enum.reject(&(occupied?(board, &1)))
    |> Enum.filter(fn {x, y} ->
      if neighbor_is_ok do
        # at this time, we only support 2-space rooms, and we only
        # care about the neighbor below the top space
        neighbor = occupied_by(board, {x, y-1})
        case neighbor do
          nil      -> true
          neighbor -> neighbor_is_ok.(player, neighbor)
        end
      else
        true
      end
    end)
    |> Enum.map(&({&1, 7}))  # FIXME 7 -> Manhattan distance
  end

  def room_occupants(board) do
    for room <- 0..board.n_rooms-1, pos <- room_pos(board, room) do
      {room, occupied_by(board, pos)}
    end
    |> Enum.reject(&(elem(&1, 1) == nil))
    |> Enum.group_by(&(elem(&1, 0)), &(elem(&1, 1)))
  end

  defp room_pos(board, room) do
    #hall_length = Enum.count(board.hall_pos) + board.n_rooms
    x_offset = div(Enum.count(board.hall_pos) - (board.n_rooms-1), 2) + 1
    0..1
    |> Enum.map(&({room*2+x_offset, &1}))
  end

  # FIXME only works for tiny
  def render(board, render_player_as \\ nil) do
    max_x = 6
    for y <- 3..-1, x <- 0..max_x do
      render_char(board, {x, y}, max_x, render_player_as)
    end
    |> Enum.chunk_every(max_x + 1)
    |> Enum.map(&to_string/1)
    |> Enum.join("\n")
    |> (fn text -> "#{text}\n" end).()
  end

  defp render_char(board, pos, max_x, render_player_as) do
    player = occupied_by(board, pos)
    cond do
      player != nil ->
        if render_player_as do
          render_player_as.(player)
        else
          ?0 + player
        end
      board_position?(pos) ->
        ?.
      corner?(pos, max_x) ->
        32  # SP
      true ->
        ?#
    end
  end

  # FIXME only works for tiny
  defp board_position?(pos) do
    [
      {1, 2}, {2, 2}, {3, 2}, {4, 2}, {5, 2},
      {2, 1}, {2, 0}, {4, 1}, {4, 0},
    ]
    |> Enum.find(&(&1 == pos))
    |> (fn v -> if v, do: true, else: false end).()
  end

  # FIXME only works for tiny
  defp corner?({x, y}, max_x) do
    cond do
      y < -1 or  y > 3      -> true
      x < 0  or  x > max_x  -> true
      y <= 0 and x == 0     -> true
      y <= 0 and x == max_x -> true
      true                  -> false
    end
  end
end
