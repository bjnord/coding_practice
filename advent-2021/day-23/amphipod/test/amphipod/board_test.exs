defmodule Amphipod.BoardTest do
  use ExUnit.Case
  doctest Amphipod.Board

  alias Amphipod.Board

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
        exp_input_new_board: %Board{
          n_rooms: 4,
          hall_pos: [
            {1, 2}, {2, 2},
            {4, 2}, {6, 2}, {8, 2},
            {10, 2}, {11, 2},
          ],
          player_pos: %{
            0 => {3, 1}, 1 => {5, 1}, 2 => {7, 1}, 3 => {9, 1},
            4 => {3, 0}, 5 => {5, 0}, 6 => {7, 0}, 7 => {9, 0},
          },
        },
        tiny_amphipos: [
          {0, {2, 1}},
          {1, {4, 1}},
          {1, {2, 0}},
          {0, {4, 0}},
        ],
        exp_tiny_new_board: %Board{
          n_rooms: 2,
          hall_pos: [
            {1, 2},
            {3, 2},
            {5, 2},
          ],
          player_pos: %{
            0 => {2, 1}, 1 => {4, 1}, 2 => {2, 0}, 3 => {4, 0},
          },
        },
      ]
    end

    test "board constructor produces expected board (tiny)", fixture do
      assert Board.new(fixture.tiny_amphipos) == fixture.exp_tiny_new_board
    end

    test "board constructor produces expected board (input)", fixture do
      assert Board.new(fixture.input_amphipos) == fixture.exp_input_new_board
    end

    test "player position get and set", fixture do
      board = Board.new(fixture.tiny_amphipos)
      assert Board.player_pos(board, 0) == {2, 1}
      upd_board = Board.update_player_pos(board, 0, {1, 2})
      assert Board.player_pos(upd_board, 0) == {1, 2}
    end

    test "invalid player position get and set", fixture do
      board = Board.new(fixture.tiny_amphipos)
      assert_raise KeyError, fn -> Board.player_pos(board, 4) end
      assert_raise KeyError, fn -> Board.update_player_pos(board, 5, {5, 2}) end
    end

    test "position occupied", fixture do
      board = Board.new(fixture.tiny_amphipos)
      assert Board.occupied?(board, {2, 1}) == true
      assert Board.occupied?(board, {1, 2}) == false
      upd_board = Board.update_player_pos(board, 0, {1, 2})
      assert Board.occupied?(upd_board, {2, 1}) == false
      assert Board.occupied?(upd_board, {1, 2}) == true
    end
  end
end
