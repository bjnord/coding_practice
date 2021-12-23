defmodule Amphipod.Game do
  @moduledoc """
  Game for `Amphipod`.
  """

  alias Amphipod.Board
  alias Amphipod.Game

  defstruct p_types: %{}, p_states: %{}, board: %Board{}, moves: [], total_cost: 0

  @doc ~S"""
  Construct new game.
  """
  def new(amphipos) do
    board = Board.new(amphipos)
    p_types =
      amphipos
      |> Enum.with_index()
      |> Enum.map(fn {{type, _pos}, n} -> {n, type} end)
      |> Enum.into(%{})
    # FIXME silliness:
    p_states =
      amphipos
      |> Enum.with_index()
      |> Enum.map(fn {{_type, _pos}, n} -> {n, :start} end)
      |> Enum.into(%{})
    %Game{
      p_types: p_types,
      p_states: p_states,
      board: board,
    }
  end

  def n_players(game), do: Enum.count(game.p_types)

  @doc ~S"""
  Return list of legal moves for `player`.

  Each return item is `{player, state, pos, cost}`.
  """
  def legal_moves(game, player) do
    case game.p_states[player] do
      :start ->
        # prioritize home moves; likely lower-cost in the end
        home_moves(game.board, player, game.p_types[player]) ++ hall_moves(game.board, player, game.p_types[player])
      :hall ->
        home_moves(game.board, player, game.p_types[player])
      :home ->
        []
    end
  end

  defp hall_moves(board, player, type) do
    Board.hall_positions_accessible_to(board, player)
    |> Enum.map(&(to_move(player, :hall, type, &1)))
  end

  defp home_moves(board, player, type) do
    # NB we've designed it so room = type
    Board.room_positions_accessible_to(board, player, type)
    # FIXME needs to reject if unfriendlies present
    |> Enum.map(&(to_move(player, :home, type, &1)))
  end

  defp to_move(player, state, _type, {pos, dist}) do
    {player, state, pos, dist*dist}  # TODO cost = dist * cost(type)
  end

  def make_move(game, {player, state, pos, cost}) do
    p_states = Map.replace!(game.p_states, player, state)
    board = Board.update_player_pos(game.board, player, pos)
    moves = [{player, state, pos, cost} | game.moves]
    total_cost = game.total_cost + cost
    %Game{game | p_states: p_states, board: board, moves: moves, total_cost: total_cost}
  end
end
