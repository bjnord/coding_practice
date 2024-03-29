defmodule Bingo do
  @moduledoc """
  Documentation for Bingo.
  """

  alias Bingo.Board, as: Board
  alias Bingo.Parser, as: Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    {balls, boards_numbers} =
      File.read!(input_file)
      |> Parser.parse(opts)
    boards_numbers
    |> Enum.map(&Board.new/1)
    |> find_first_winner(balls)
    |> (fn board -> board.score end).()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Play bingo, finding the first winning board.
  """
  def find_first_winner(boards, balls, winner \\ nil)
  def find_first_winner(_boards, _balls, winner) when winner != nil, do: winner
  def find_first_winner(boards, [ball | balls], _winner) do
    boards = Enum.map(boards, &(Board.mark_board(&1, ball)))
    winner = Enum.find(boards, &Board.has_score?/1)
    find_first_winner(boards, balls, winner)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    {balls, boards} =
      File.read!(input_file)
      |> Parser.parse(opts)
    boards
    |> Enum.map(&Board.new/1)
    |> find_last_winner(balls)
    |> (fn board -> board.score end).()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Play bingo, finding the last winning board.
  """
  def find_last_winner(boards, balls, win_count \\ nil)
  def find_last_winner(boards, balls, win_count) when win_count == 1 do
    Enum.find(boards, &board_doesnt_have_score?/1)
    |> play_until_board_wins(balls, false)
  end
  def find_last_winner(boards, [ball | balls], _win_count) do
    boards = Enum.map(boards, &(Board.mark_board(&1, ball)))
    win_count = Enum.count(boards, &board_doesnt_have_score?/1)
    find_last_winner(boards, balls, win_count)
  end

  defp board_doesnt_have_score?(board) do
    !Board.has_score?(board)
  end

  defp play_until_board_wins(board, _balls, won) when won, do: board
  defp play_until_board_wins(board, [ball | balls], _won) do
    board = Board.mark_board(board, ball)
    play_until_board_wins(board, balls, Board.has_score?(board))
  end
end
