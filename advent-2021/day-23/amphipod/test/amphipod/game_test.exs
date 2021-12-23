defmodule Amphipod.GameTest do
  use ExUnit.Case
  doctest Amphipod.Game

  alias Amphipod.Game

  describe "puzzle example" do
    setup do
      [
        input_amphipos: [
          {1, {3, 1}},
          {2, {5, 1}},
          {1, {7, 1}},
          {3, {9, 1}},
          {0, {3, 0}},
          {3, {5, 0}},
          {2, {7, 0}},
          {0, {9, 0}},
        ],
        exp_input_n_players: 8,
        tiny_amphipos: [
          {0, {2, 1}},
          {1, {4, 1}},
          {1, {2, 0}},
          {0, {4, 0}},
        ],
        exp_tiny_n_players: 4,
        exp_tiny_initial_legal_moves: [
          # TODO
        ],
      ]
    end

    test "n_players (initial tiny)", fixture do
      game = Game.new(fixture.tiny_amphipos)
      assert Game.n_players(game) == fixture.exp_tiny_n_players
    end

    test "n_players (initial input)", fixture do
      game = Game.new(fixture.input_amphipos)
      assert Game.n_players(game) == fixture.exp_input_n_players
    end

    test "strangers", fixture do
      game = Game.new(fixture.tiny_amphipos)
      assert Game.strangers?(game, 0, 1) == true
      assert Game.strangers?(game, 0, 2) == true
      assert Game.strangers?(game, 0, 3) == false
      assert Game.strangers?(game, 1, 1) == false
    end

    test "winning game (tiny)", fixture do
      game =
        Game.new(fixture.tiny_amphipos)
        |> Game.play()
      #Game.render(game, false)
      assert Game.won?(game) == true
    end

    @tag :pending
    test "winning game (input)", fixture do
      # NOTE FIXME in `Board.room_pos()` needed for input case to work
      game =
        Game.new(fixture.input_amphipos)
        |> Game.play()
      assert Game.won?(game) == true
    end
  end
end
