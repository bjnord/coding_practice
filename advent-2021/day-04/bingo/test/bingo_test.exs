defmodule BingoTest do
  use ExUnit.Case
  doctest Bingo

  describe "puzzle example" do
    setup do
      [
        input: """
          7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
  
          22 13 17 11  0
           8  2 23  4 24
          21  9 14 16  7
           6 10  3 18  5
           1 12 20 15 19
  
           3 15  0  2 22
           9 18 13 17  5
          19  8  7 25 23
          20 11 10 24  4
          14 21 16 12  6
  
          14 21 17 24  4
          10 16 15  9 19
          18  8 23 26 20
          22 11 13  6  5
           2  0 12  3  7
        """,
        exp_balls: [7, 4, 9, 5, 11, 17, 23, 2, 0, 14, 21, 24, 10, 16, 13, 6, 15, 25, 12, 22, 18, 20, 8, 19, 3, 26, 1], 
        exp_boards: [
          {[22, 13, 17, 11, 0, 8, 2, 23, 4, 24, 21, 9, 14, 16, 7, 6, 10, 3, 18, 5, 1, 12, 20, 15, 19], 0b0, nil},
          {[3, 15, 0, 2, 22, 9, 18, 13, 17, 5, 19, 8, 7, 25, 23, 20, 11, 10, 24, 4, 14, 21, 16, 12, 6], 0b0, nil},
          {[14, 21, 17, 24, 4, 10, 16, 15, 9, 19, 18, 8, 23, 26, 20, 22, 11, 13, 6, 5, 2, 0, 12, 3, 7], 0b0, nil},
        ],
        exp_marks: [
          0b0000010000100100100001000,
          0b0000010010001001000100000,
          0b1000010010000000100010000,
        ],
      ]
    end

    test "parser gets expected balls and boards", fixture do
      assert Bingo.CLI.parse_input(fixture.input) == {fixture.exp_balls, fixture.exp_boards}
    end

    test "board marker", fixture do
      first_called = Enum.take(fixture.exp_balls, 5)
      # FIXME run test for all boards, not just first
      board = Enum.at(fixture.exp_boards, 0)
      marked_board = first_called
                     |> Enum.reduce(board, fn (called, board) ->
                       Bingo.mark_board(board, called)
                     end)
      assert elem(marked_board, 1) == Enum.at(fixture.exp_marks, 0)
    end

    test "board marker scoring" do
      board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b0, nil}
      # 1. call two numbers in a column, plus one not on the card (hasn't won yet)
      board = [7, 2, 10]
              |> Enum.reduce(board, fn (called, board) -> Bingo.mark_board(board, called) end)
      assert board == {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b000100100, nil}
      # 2. call two more numbers, one of which completes the column (wins)
      board = [3, 6]
              |> Enum.reduce(board, fn (called, board) -> Bingo.mark_board(board, called) end)
      assert board == {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b100101100, (4+9+5+1+8)*6}
      # 3. call another number on the card (should not change score)
      board = [8]
              |> Enum.reduce(board, fn (called, board) -> Bingo.mark_board(board, called) end)
      assert board == {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b101101100, (4+9+5+1+8)*6}
    end

    test "board win tester, just before winning number called", fixture do
      first_called = Enum.take(fixture.exp_balls, 11)
      board = Enum.at(fixture.exp_boards, 2)
      marked_board = first_called
                     |> Enum.reduce(board, fn (called, board) ->
                       Bingo.mark_board(board, called)
                     end)
      assert Bingo.winning_board?(marked_board) == false
    end

    test "board win tester, after winning number called", fixture do
      first_called = Enum.take(fixture.exp_balls, 12)
      board = Enum.at(fixture.exp_boards, 2)
      marked_board = first_called
                     |> Enum.reduce(board, fn (called, board) ->
                       Bingo.mark_board(board, called)
                     end)
      assert Bingo.winning_board?(marked_board) == true
    end

    test "first winning board finder", fixture do
      exp_winning_board = Enum.at(fixture.exp_boards, 2)
      act_winning_board = fixture.exp_boards
                          |> Bingo.find_first_winning_board(fixture.exp_balls)
      assert elem(act_winning_board, 0) == elem(exp_winning_board, 0)
      assert elem(act_winning_board, 2) == 4512
    end

    test "last winning board finder", fixture do
      exp_winning_board = Enum.at(fixture.exp_boards, 1)
      act_winning_board = fixture.exp_boards
                          |> Bingo.find_last_winning_board(fixture.exp_balls)
      assert elem(act_winning_board, 0) == elem(exp_winning_board, 0)
      assert elem(act_winning_board, 2) == 1924
    end
  end
end
