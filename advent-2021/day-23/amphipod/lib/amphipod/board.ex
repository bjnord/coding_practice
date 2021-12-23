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

  defstruct n_rooms: 0, hall_pos: [], player_pos: %{}, pos_player: %{}

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
    pos_player =
      amphipos
      |> Enum.with_index()
      |> Enum.map(fn {{_type, pos}, n} -> {pos, n} end)
      |> Enum.into(%{})
    %Board{
      n_rooms: n_rooms,
      hall_pos: hall_positions(n_rooms, min_x, max_x),
      player_pos: player_pos,
      pos_player: pos_player,
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
    case board.player_pos[player] do
      nil -> raise KeyError, "player #{player} not found on board"
      pos -> pos
    end
  end

  @doc ~S"""
  Update player position on board.

  Raises `KeyError` if the given `player` is not found.
  """
  def update_player_pos(board, player, pos) do
    old_pos = player_pos(board, player)
    if board.pos_player[pos] != nil do
      raise KeyError, "player #{board.pos_player[pos]} already occupies #{pos}"
    end
    pos_player =
      board.pos_player
      |> Map.delete(old_pos)
      |> Map.put(pos, player)
    %Board{board |
      player_pos: Map.replace!(board.player_pos, player, pos),
      pos_player: pos_player,
    }
  end

  @doc ~S"""
  Is the given position occupied by a player?
  """
  def occupied?(board, pos) do
    if board.pos_player[pos], do: true, else: false
  end

  @doc ~S"""
  Return list of hall positions currently accessible to the given `player`.

  Each return item is `{pos, dist}`.
  """
  def hall_positions_accessible_to(board, player) do
    ###
    # we don't currently support hall-to-hall moves
    # so a to-hall move is always (1) up to the hallway
    {x, y} = board.player_pos[player]
    v_blocked = vert_path_blocked?(board, {x, y+1}, {x, 2})
    ###
    # (2) and then right/left
    cond do
      v_blocked ->
        []
      true      ->
        board.hall_pos
        |> Enum.reject(&(horiz_path_blocked?(board, {x, 2}, &1)))
        |> Enum.map(&({&1, 8}))  # FIXME 8 -> Manhattan distance
    end
  end

  defp horiz_path_blocked?(board, {x0, 2}, {x1, 2}) do
    # (don't include the x0 position in the check; it's either where the
    # player is now, or it was already tested with the to-hall check)
    x0..x1
    |> Enum.any?(fn x -> x != x0 and occupied?(board, {x, 2}) end)
  end

  defp vert_path_blocked?(board, {x, y0}, {x, y1}) do
    y0..y1
    |> Enum.any?(fn y -> occupied?(board, {x, y}) end)
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
    room_pos(board, room)
    |> Enum.reject(&(path_to_room_blocked?(board, board.player_pos[player], &1)))
    |> Enum.filter(fn {x, y} ->
      if neighbor_is_ok do
        # at this time, we only support 2-space rooms, and we only
        # care about the neighbor below the top space
        neighbor = board.pos_player[{x, y-1}]
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

  defp path_to_room_blocked?(board, {x0, y0}, {x1, y1}) do
    ###
    # we could be starting from a different room (up-and-over)
    # so first get up to the hallway if needed
    v1_blocked =
      if y0 > 2 do
        vert_path_blocked?(board, {x0, y0+1}, {x0, 2})
      else
        false  # already in the hallway
      end
    ###
    # now check the left/right traverse
    h_blocked = horiz_path_blocked?(board, {x0, 2}, {x1, 2})
    ###
    # last check the move down to final destination
    v2_blocked = vert_path_blocked?(board, {x1, 3}, {x1, y1})
    v1_blocked or h_blocked or v2_blocked
  end

  def room_occupants(board) do
    for room <- 0..board.n_rooms-1, pos <- room_pos(board, room) do
      {room, board.pos_player[pos]}
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
    player = board.pos_player[pos]
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
