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
          hallway_pos: [
            {1, 2}, {2, 2},
            {4, 2}, {6, 2}, {8, 2},
            {10, 2}, {11, 2},
          ],
        },
        tiny_amphipos: [
          {0, {2, 1}},
          {1, {4, 1}},
          {1, {2, 0}},
          {0, {4, 0}},
        ],
        exp_tiny_new_board: %Board{
          n_rooms: 2,
          hallway_pos: [
            {1, 2},
            {3, 2},
            {5, 2},
          ],
        },
      ]
    end

    test "board constructor produces expected board (tiny)", fixture do
      assert Board.new(fixture.tiny_amphipos) == fixture.exp_tiny_new_board
    end

    test "board constructor produces expected board (input)", fixture do
      assert Board.new(fixture.input_amphipos) == fixture.exp_input_new_board
    end
  end
end
