defmodule Bingo do
  @moduledoc """
  Documentation for Bingo.
  """

  import Bingo.CLI
  import Math
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
                      |> parse_input
    IO.puts("Part 1 answer is TODO")
  end

  @doc """
  Mark board with called number.

  ## Examples
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0, 0}
      iex> board = Bingo.mark_board(board, 7)
      {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b00100000, 7}
      iex> board = Bingo.mark_board(board, 4)
      {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b00100001, 11}
      iex> board = Bingo.mark_board(board, 10)
      {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b00100001, 11}
  """
  def mark_board({squares, called_bits, called_sum}, called) do
    case Enum.find_index(squares, fn sq -> sq == called end) do
      nil -> {squares, called_bits, called_sum}
      i -> {squares, called_bits ||| Bitwise.bsl(1, i), called_sum + called}
    end
  end

  @doc """
  Determine if marked board wins.

  ## Examples
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b011000001, 9+2+6}
      iex> Bingo.winning_board?(board)
      false
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b011001001, 9+(2+7+6)}
      iex> Bingo.winning_board?(board)
      true
      iex> board = {[4, 9, 2, 3, 5, 7, 8, 1, 6], 0b111000001, (4+9+2)+6}
      iex> Bingo.winning_board?(board)
      true
  """
  def winning_board?({squares, called_bits, _called_sum}) do
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
  Transpose a two-dimensional array.

  h/t [this StackOverflow answer](https://stackoverflow.com/a/23706084/291754)

  ## Examples
      iex> Bingo.transpose([[1, 2], [3, 4], [5, 6]])
      [[1, 3, 5], [2, 4, 6]]
  """
  def transpose([[] | _]), do: []
  def transpose(a) do
      [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    IO.puts("Part 2 answer is TODO")
  end
end
