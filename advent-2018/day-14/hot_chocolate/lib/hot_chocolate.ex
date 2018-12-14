defmodule HotChocolate do
  @moduledoc """
  Documentation for HotChocolate.
  """

  import HotChocolate.CLI

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    input_file = parse_args(argv)
    part1(input_file)
    part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: '2810862211'
  """
  def part1(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> run_trials_p1
    |> IO.inspect(label: "Part 1 ten-recipe score(s) are")
  end

  defp run_trials_p1(trials) do
    trials
    |> Enum.map(fn (n_recipes) ->
      acc = {HotChocolate.Scoreboard.new([3, 7]), 0, 1}
      1..n_recipes+10
      |> Enum.reduce(acc, fn (_n, {board, elf1_i, elf2_i}) ->
        trial_step({board, elf1_i, elf2_i})
      end)
      |> elem(0)
      |> HotChocolate.Scoreboard.slice(n_recipes, 10)
      |> Enum.map(fn (score) -> score + ?0 end)
    end)
  end

  defp trial_step({board, elf1_i, elf2_i}) do
    board = HotChocolate.Scoreboard.create(board, elf1_i, elf2_i)
    elf1_s = HotChocolate.Scoreboard.get(board, elf1_i)
    elf1_i = HotChocolate.Scoreboard.inc_index(board, elf1_i, 1 + elf1_s)
    elf2_s = HotChocolate.Scoreboard.get(board, elf2_i)
    elf2_i = HotChocolate.Scoreboard.inc_index(board, elf2_i, 1 + elf2_s)
    {board, elf1_i, elf2_i}
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: 20227889
  """
  def part2(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&String.trim/1)
    |> Enum.map(&HotChocolate.to_scores/1)
    |> run_trials_p2
    |> IO.inspect(label: "Part 2 ten-recipe count(s) are")
  end

  def to_scores(line) when is_binary(line) do
    String.to_charlist(line)
    |> Enum.map(fn (char) -> char - ?0 end)
  end

  defp run_trials_p2(trials) do
    trials
    |> Enum.map(fn (score_pattern) ->
      n_scores = Enum.count(score_pattern)
      acc = {HotChocolate.Scoreboard.new([3, 7]), 0, 1}
      1..1_000_000_000
      |> Enum.reduce_while(acc, fn (_n, {board, elf1_i, elf2_i}) ->
        {board, elf1_i, elf2_i} = trial_step({board, elf1_i, elf2_i})
        # tricky! since create() can possibly add 2 new recipes,
        # need to check the pattern one index back as well
        latest_scores =
          HotChocolate.Scoreboard.slice(board, -n_scores, n_scores)
        latest_scores_n1 =
          HotChocolate.Scoreboard.slice(board, -n_scores-1, n_scores)
        cond do
          latest_scores_n1 == score_pattern ->
            {:halt, HotChocolate.Scoreboard.count(board) - n_scores - 1}
          latest_scores == score_pattern ->
            {:halt, HotChocolate.Scoreboard.count(board) - n_scores}
          true ->
            {:cont, {board, elf1_i, elf2_i}}
        end
      end)
    end)
  end
end
