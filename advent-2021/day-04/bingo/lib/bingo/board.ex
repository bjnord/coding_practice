defmodule Bingo.Board do
  @moduledoc """
  Board for `Bingo`.
  """

  alias Bingo.Board, as: Board
  use Bitwise

  defstruct dim: 5, squares: [], marks: 0b0, score: nil

  @doc ~S"""
  Create new `Bingo.Board` from list of squares.

  ## Examples
      iex> Bingo.Board.new([2, 7, 6, 9, 5, 1, 4, 3, 8], dim: 3)
      %Bingo.Board{dim: 3, squares: [2, 7, 6, 9, 5, 1, 4, 3, 8],
        marks: 0b0, score: nil}
  """
  def new(squares, opts \\ []) do
    opts = Keyword.merge([dim: 5], opts)
    %Board{
      dim: opts[:dim],
      squares: squares,
    }
  end

  @doc """
  Mark board with called number. If board wins, set the winning score.

  ## Examples
      iex> board = %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b0, score: nil}
      iex> board = Bingo.Board.mark_board(board, 7)
      %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b000100000, score: nil}
      iex> board = Bingo.Board.mark_board(board, 4)
      %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b000100001, score: nil}
      iex> _board = Bingo.Board.mark_board(board, 10)
      %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b000100001, score: nil}
  """
  def mark_board(board, called) do
    marked_board =
      case Enum.find_index(board.squares, &(&1 == called)) do
        nil -> board
        i -> %Board{board | marks: board.marks ||| Bitwise.bsl(1, i)}
      end
    # the `true, nil` check is so we only set the score once, so
    # subsequent markings will not affect the score at win time
    case {winning_board?(marked_board), board.score} do
      {true, nil} -> score_board(marked_board, called)
      {_, _} -> marked_board
    end
  end

  defp score_board(board, called) do
    %Board{board | score: uncalled_sum(board) * called}
  end

  @doc """
  Determine if marked board wins.

  ## Examples
      iex> board = %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b011000001, score: nil}
      iex> Bingo.Board.winning_board?(board)
      false
      iex> board = %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b011001001, score: nil}
      iex> Bingo.Board.winning_board?(board)
      true
      iex> board = %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b111000001, score: nil}
      iex> Bingo.Board.winning_board?(board)
      true
  """
  # TODO RF can this be done more simply with bitstrings?
  # TODO RF can winning_column?() replace Submarine.transpose() ?
  def winning_board?(board) do
    bit_grid = board.marks
               |> Integer.to_string(2)
               |> String.pad_leading(board.dim * board.dim, "0")
               |> String.to_charlist()
               |> Enum.map(fn b -> b &&& 1 end)
               |> Enum.chunk_every(board.dim)
    row_marked = bit_grid
                 |> Enum.map(&winning_row?/1)
                 |> Enum.any?()
    column_marked = bit_grid
                    |> Submarine.transpose()
                    |> Enum.map(&winning_row?/1)
                    |> Enum.any?()
    row_marked || column_marked
  end

  defp winning_row?(row) do
    row
    |> Enum.all?(fn bit -> bit == 1 end)
  end

  @doc """
  Calculate sum of uncalled numbers on board.

  ## Examples
      iex> board = %Bingo.Board{dim: 3, squares: [4, 9, 2, 3, 5, 7, 8, 1, 6], marks: 0b100100110, score: nil}  # 9,2,7,6
      iex> Bingo.Board.uncalled_sum(board)
      4+3+5+8+1
  """
  def uncalled_sum(board) do
    board.squares
    |> Enum.reduce({0, 0b1}, fn (ball, {sum, mask}) ->
      {sum + uncalled_ball_value(ball, (board.marks &&& mask)), mask * 2}
    end)
    |> elem(0)
  end

  defp uncalled_ball_value(ball, bit) when bit == 0b0, do: ball
  defp uncalled_ball_value(_ball, _bit), do: 0

  @doc """
  Does board have a score?
  """
  def has_score?(board) do
    board.score != nil
  end
end
