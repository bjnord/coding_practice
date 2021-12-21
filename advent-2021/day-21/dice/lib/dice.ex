defmodule Dice do
  @moduledoc """
  Documentation for Dice.
  """

  alias Dice.Parser, as: Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # "Play a practice game using the deterministic 100-sided die. The
    # moment either player wins, what do you get if you multiply the score
    # of the losing player by the number of times the die was rolled during
    # the game?"
    {scores, _positions, turns, _die} =
      File.read!(input_file)
      |> Parser.parse()
      |> play()
    part1_answer({scores, turns})
    |> IO.inspect(label: "Part 1 answer is")
  end

  def part1_answer({scores, turns}) do
    losing_score = Enum.min(Tuple.to_list(scores))
    losing_score * (turns * 3)
  end

  @doc """
  Play a game of Dirac Dice.
  """
  def play({start_p1, start_p2}) do
    Stream.cycle([0, 1])
    |> Enum.reduce_while({{0, 0}, {start_p1, start_p2}, 0, 1}, fn (player, {scores, positions, turns, die}) ->
      # this is the "100-sided deterministic die" for part 1
      move = die + (die + 1) + (die + 2)
      die = rem((die - 1) + 3, 100) + 1
      position = rem((elem(positions, player) - 1) + move, 10) + 1
      score = elem(scores, player) + position
      cont_halt = if score >= 1000, do: :halt, else: :cont
      {
        cont_halt,
        {
          put_elem(scores, player, score),
          put_elem(positions, player, position),
          turns + 1,
          die,
        },
      }
    end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
