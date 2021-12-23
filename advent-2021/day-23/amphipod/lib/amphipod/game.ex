defmodule Amphipod.Game do
  @moduledoc """
  Game for `Amphipod`.
  """

  alias Amphipod.Board
  alias Amphipod.Game

  defstruct players: %{}, board: %Board{}, moves: [], total_cost: 0

  @doc ~S"""
  Construct new game.
  """
  def new(amphipos) do
    board = Board.new(amphipos)
    players =
      amphipos
      |> Enum.with_index()
      |> Enum.map(fn {{type, _pos}, n} -> {n, {type, :start}} end)
      |> Enum.into(%{})
    %Game{
      players: players,
      board: board,
    }
  end

  def n_players(game), do: Enum.count(game.players)

  @doc ~S"""
  Return list of legal moves for `player`.

  Each return item is `{player, state, pos, cost}`.
  """
  def legal_moves(game, player) do
    {type, state} = game.players[player]
    case state do
      :start ->
        hall_moves(game.board, player, type) ++ home_moves(game.board, player, type)
      :hall ->
        home_moves(game.board, player, type)
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
    {type, _state} = game.players[player]
    players = Map.replace!(game.players, player, {type, state})
    board = Board.update_player_pos(game.board, player, pos)
    moves = [{player, state, pos, cost} | game.moves]
    total_cost = game.total_cost + cost
    %Game{players: players, board: board, moves: moves, total_cost: total_cost}
  end
end
