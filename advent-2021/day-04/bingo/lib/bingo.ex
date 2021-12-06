defmodule Bingo do
  @moduledoc """
  Documentation for Bingo.
  """

  import Bingo.Parser
  import Submarine
  import Submarine.CLI
  use Bitwise

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
    {balls, boards} = input_file
                      |> File.read!
                      |> parse_input(opts)
    boards
    |> find_first_winning_board(balls)
    |> elem(2)  # score
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Mark board with called number.

  ## Examples
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b0, nil}
      iex> board = Bingo.mark_board(board, 7)
      {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b000100000, nil}
      iex> board = Bingo.mark_board(board, 4)
      {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b000100001, nil}
      iex> _board = Bingo.mark_board(board, 10)
      {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b000100001, nil}
  """
  def mark_board({squares, called_bits, score}, called) do
    marked_board =
      case Enum.find_index(squares, fn sq -> sq == called end) do
        nil -> {squares, called_bits, score}
        i -> {squares, called_bits ||| Bitwise.bsl(1, i), score}
      end
    # the `true, nil` check is so we only set the score once, so
    # subsequent markings will not affect the score at win time
    case {winning_board?(marked_board), score} do
      {true, nil} -> score_board(marked_board, called)
      {_, _} -> marked_board
    end
  end
  defp score_board({squares, called_bits, _score}, called) do
    score = uncalled_sum({squares, called_bits, nil}) * called
    {squares, called_bits, score}
  end

  @doc """
  Determine if marked board wins.

  ## Examples
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b011000001, nil}
      iex> Bingo.winning_board?(board)
      false
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b011001001, nil}
      iex> Bingo.winning_board?(board)
      true
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b111000001, nil}
      iex> Bingo.winning_board?(board)
      true
  """
  def winning_board?({squares, called_bits, _score}) do
    dim = Math.isqrt(Enum.count(squares))
    bit_grid = called_bits
               |> Integer.to_string(2)
               |> String.pad_leading(dim * dim, "0")
               |> String.to_charlist
               |> Enum.map(fn b -> b &&& 1 end)
               |> Enum.chunk_every(dim)
    row_marked = bit_grid
                 |> Enum.map(&Bingo.winning_row?/1)
                 |> Enum.any?
    column_marked = bit_grid
                    |> transpose
                    |> Enum.map(&Bingo.winning_row?/1)
                    |> Enum.any?
    row_marked || column_marked
  end
  def winning_row?(row) do
    row
    |> Enum.all?(fn bit -> bit == 1 end)
  end

  @doc """
  Play bingo, finding the first winning board.
  """
  def find_first_winning_board(boards, [ball | next_balls]) do
    next_boards = boards
                  |> Enum.map(fn board -> mark_board(board, ball) end)
    case Enum.find(next_boards, &Bingo.board_has_score?/1) do
      nil -> find_first_winning_board(next_boards, next_balls)
      winning_board -> winning_board
    end
  end
  def board_has_score?({_squares, _called_bits, score}) do
    score != nil
  end

  @doc """
  Calculate sum of uncalled numbers on board.

  ## Examples
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b100100110, nil}  # called=9,2,7,6
      iex> Bingo.uncalled_sum(board)
      4+3+5+8+1
  """
  def uncalled_sum({squares, called_bits, _score}) do
    squares
    |> Enum.reduce({0, 0b1}, fn (ball, {sum, mask}) ->
      called = if (called_bits &&& mask) == 0b0, do: ball, else: 0
      {sum + called, mask * 2}
    end)
    |> elem(0)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    {balls, boards} = input_file
                      |> File.read!
                      |> parse_input(opts)
    boards
    |> find_last_winning_board(balls)
    |> elem(2)  # score
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Play bingo, finding the last winning board.
  """
  def find_last_winning_board(boards, [ball | next_balls]) do
    next_boards = boards
                  |> Enum.map(fn board -> mark_board(board, ball) end)
    case Enum.count(next_boards, &Bingo.board_doesnt_have_score?/1) do
      1 -> Enum.find(next_boards, &Bingo.board_doesnt_have_score?/1)
           |> play_until_board_wins(next_balls)
      _ -> find_last_winning_board(next_boards, next_balls)
    end
  end
  def board_doesnt_have_score?({_squares, _called_bits, score}) do
    score == nil
  end
  defp play_until_board_wins(board, balls) do
    balls
    |> Enum.reduce_while(board, fn (ball, board) ->
      board = mark_board(board, ball)
      if board_has_score?(board), do: {:halt, board}, else: {:cont, board}
    end)
  end
end
