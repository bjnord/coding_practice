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
  def total_cost(game), do: game.total_cost

  @doc ~S"""
  Play the game.
  """
  def play(game), do: play(game, game)
  def play(game, best_game) do
    next_moves =
      Map.keys(game.p_states)
      |> Enum.flat_map(fn player -> legal_moves(game, player) end)
      |> Enum.sort_by(&(elem(&1, 3)))  # cost
    # FIXME rewrite this with initial / base case guards
    if next_moves == [] do
      if Game.won?(game) do
        #IO.puts("leaf: won in #{Enum.count(game.moves)} moves")
        game
      else
        # deadlock: return with infinitely high cost
        #IO.puts("leaf: deadlocked in #{Enum.count(game.moves)} moves")
        %Game{game | total_cost: nil}
      end
    else
      next_moves
      |> Enum.sort_by(&(elem(&1, 3)))  # try lowest-cost first
      |> Enum.reduce(best_game, fn (move, best_game) ->
        if worse_cost(game, move, best_game) do
          #IO.puts("leaf: tossed")
          best_game  # already worse than our known best; skip move
        else
          game_w_move = play(make_move(game, move))
          cond do
            !Game.won?(best_game) ->
              game_w_move  # just getting started
            Game.won?(game) and (game_w_move.total_cost < best_game.total_cost) ->
              game_w_move  # our child found a better winner
            true ->
              best_game
          end
        end
      end)
    end
  end

  defp worse_cost(game, move, best_game) do
    IO.inspect({Enum.count(game.moves), game.total_cost, elem(move, 3),
      Enum.count(best_game.moves), best_game.total_cost, Game.won?(best_game)},
      label: "worse_cost?")
    cond do
      !Game.won?(best_game) ->
        false  # just getting started
      game.total_cost + elem(move, 3) >= best_game.total_cost ->
        true
      true ->
        false
    end
  end

  @doc ~S"""
  Has the game achieved a winning outcome?
  """
  def won?(game) do
    occupants = Board.room_occupants(game.board)
    uniform =
      occupants
      |> Enum.all?(fn {room, players} ->
        Enum.all?(players, &(game.p_types[&1] == room))
      end)
    n_home =
      occupants
      |> Enum.flat_map(fn {_room, room_players} -> room_players end)
      |> Enum.count()
    cond do
      uniform and n_home == n_players(game) -> true
      true                                  -> false
    end
  end

  def render(game, show_next_moves \\ false) do
    igame = Game.new(game.amphipos)
    render_move(igame, 0, show_next_moves)
    game.moves
    |> Enum.reverse()
    |> Enum.reduce({igame, 1}, fn (move, {igame, n}) ->
      igame = make_move(igame, move)
      render_move(igame, n, show_next_moves)
      {igame, n+1}
    end)
  end

  defp render_move(game, n, show_next_moves) do
    n_s = String.pad_leading(Integer.to_string(n), 2, " ")
    c_s = String.pad_leading(Integer.to_string(game.total_cost), 4, " ")
    IO.puts("/-- #{n_s} -- $#{c_s} --\\")
    Board.render(game.board, render_player_as(game))
    |> IO.puts()
    if show_next_moves do
      IO.puts("----")
      Map.keys(game.p_types)
      |> Enum.each(fn player ->
        IO.inspect(legal_moves(game, player), label: "player #{player} legal moves")
      end)
    end
    IO.puts("")
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
    |> Enum.sort_by(fn {{_x, y}, _dist} -> y end)
    |> Enum.take(1)  # only use the lowest available
    |> Enum.map(&(to_move(player, :home, type, &1)))
  end

  defp neighbor_is_ok(game) do
    fn (player, neighbor) -> !strangers?(game, player, neighbor) end
  end

  defp to_move(player, state, type, {pos, dist}) do
    {player, state, pos, dist * cost_of_type(type)}
  end

  defp cost_of_type(type) do
    :math.pow(10, type)
    |> round()
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
