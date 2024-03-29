defmodule Bingo.BoardTest do
  use ExUnit.Case
  import TestHelper
  doctest Bingo.Board

  alias Bingo.Board, as: Board

  describe "puzzle example" do
    setup do
      [
        balls: [7, 4, 9, 5, 11, 17, 23, 2, 0, 14, 21, 24, 10, 16, 13, 6, 15, 25, 12, 22, 18, 20, 8, 19, 3, 26, 1],
        boards: [
          %Board{
            dim: 5,
            squares: [22, 13, 17, 11, 0, 8, 2, 23, 4, 24, 21, 9, 14, 16, 7, 6, 10, 3, 18, 5, 1, 12, 20, 15, 19],
            marks: 0b0,
            score: nil,
          },
          %Board{
            dim: 5,
            squares: [3, 15, 0, 2, 22, 9, 18, 13, 17, 5, 19, 8, 7, 25, 23, 20, 11, 10, 24, 4, 14, 21, 16, 12, 6],
            marks: 0b0,
            score: nil,
          },
          %Board{
            dim: 5,
            squares: [14, 21, 17, 24, 4, 10, 16, 15, 9, 19, 18, 8, 23, 26, 20, 22, 11, 13, 6, 5, 2, 0, 12, 3, 7],
            marks: 0b0,
            score: nil,
          },
        ],
        exp_marks: [
          0b0000010000100100100001000,
          0b0000010010001001000100000,
          0b1000010010000000100010000,
        ],
      ]
    end

    test "board marker", fixture do
      balls = Enum.take(fixture.balls, 5)
      act_marks = fixture.boards
                  |> Enum.map(fn board ->
                    mark_board_for_balls(board, balls)
                    |> (fn board -> board.marks end).()
                  end)
      assert act_marks == fixture.exp_marks
    end

    test "board marker scoring" do
      board = %Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b0, score: nil}
      # 1. call two numbers in a column, plus one not on the card (hasn't won yet)
      board = mark_board_for_balls(board, [7, 2, 10])
      assert board == %Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b000100100, score: nil}
      # 2. call two more numbers, one of which completes the column (wins)
      board = mark_board_for_balls(board, [3, 6])
      assert board == %Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b100101100, score: (4+9+5+1+8)*6}
      # 3. call another number on the card (should not change score)
      board = mark_board_for_balls(board, [8])
      assert board == %Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b101101100, score: (4+9+5+1+8)*6}
    end

    test "board win tester, just before winning number called", fixture do
      balls = Enum.take(fixture.balls, 11)
      board = Enum.at(fixture.boards, 2)
              |> mark_board_for_balls(balls)
      assert Board.winning_board?(board) == false
    end

    test "board win tester, after winning number called", fixture do
      balls = Enum.take(fixture.balls, 12)
      board = Enum.at(fixture.boards, 2)
              |> mark_board_for_balls(balls)
      assert Board.winning_board?(board) == true
    end
  end
end
