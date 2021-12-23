defmodule Amphipod.Game do
  @moduledoc """
  Game for `Amphipod`.
  """

  alias Amphipod.Board
  alias Amphipod.Game

  defstruct p_types: %{}, p_states: %{}, board: %Board{}, moves: [], total_cost: 0, amphipos: nil

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
      amphipos: amphipos,
    }
  end

  def n_players(game), do: Enum.count(game.p_types)

  @doc ~S"""
  Play the game.
  """
  def play(game) do
    moves =
      Map.keys(game.p_states)
      |> Enum.flat_map(fn player -> legal_moves(game, player) end)
    # FIXME rewrite this with initial / base case guards
    if moves == [] do
      game
    else
      game =
        List.first(moves)
        |> (fn move -> make_move(game, move) end).()
      play(game)
    end
  end

  @doc ~S"""
  Has the game achieved a winning outcome?
  """
  def won?(game) do
    Board.room_occupants(game.board)
    |> Enum.all?(fn {room, players} ->
      Enum.all?(players, &(game.p_types[&1] == room))
    end)
  end

  def render(game) do
    igame = Game.new(game.amphipos)
    game.moves
    |> Enum.reverse()
    |> Enum.reduce({igame, 1}, fn (move, {igame, n}) ->
      igame = make_move(igame, move)
      n_s = String.pad_leading(Integer.to_string(n), 2, " ")
      c_s = String.pad_leading(Integer.to_string(igame.total_cost), 4, " ")
      IO.puts("/-- #{n_s} -- $#{c_s} --\\")
      Board.render(igame.board, render_player_as(game))
      |> IO.puts()
      IO.puts("")
      {igame, n+1}
    end)
  end

  defp render_player_as(game) do
    fn (player) ->
      base = if rem(player, 2) == 1, do: ?a, else: ?A
      game.p_types[player] + base
    end
  end

  @doc ~S"""
  Return list of legal moves for `player`.

  Each return item is `{player, state, pos, cost}`.
  """
  def legal_moves(game, player) do
    case game.p_states[player] do
      :start ->
        # prioritize home moves; likely lower-cost in the end
        home_moves(game, player, game.p_types[player]) ++ hall_moves(game, player, game.p_types[player])
      :hall ->
        home_moves(game, player, game.p_types[player])
      :home ->
        []
    end
  end

  defp hall_moves(game, player, type) do
    Board.hall_positions_accessible_to(game.board, player)
    |> Enum.map(&(to_move(player, :hall, type, &1)))
  end

  defp home_moves(game, player, type) do
    # NB we've designed it so room = type
    Board.room_positions_accessible_to(game.board, player, type, neighbor_is_ok(game))
    |> Enum.sort_by(fn {_x, y} -> y end)
    |> Enum.take(1)  # only use the lowest available
    |> Enum.map(&(to_move(player, :home, type, &1)))
  end

  defp neighbor_is_ok(game) do
    fn (player, neighbor) -> !strangers?(game, player, neighbor) end
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

  def strangers?(game, player1, player2) do
    game.p_types[player1] != game.p_types[player2]
  end
end
