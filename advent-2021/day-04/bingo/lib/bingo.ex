defmodule Bingo do
  @moduledoc """
  Documentation for Bingo.
  """

  import Bingo.CLI
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
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    IO.puts("Part 2 answer is TODO")
  end
end
