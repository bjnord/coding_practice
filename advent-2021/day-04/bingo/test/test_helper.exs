ExUnit.start()

defmodule TestHelper do
  def mark_board_for_balls(board, balls) do
    balls
    |> Enum.reduce(board, fn (called, board) ->
      Bingo.Board.mark_board(board, called)
    end)
  end
end
