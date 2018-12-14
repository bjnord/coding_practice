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
    {input_file, parts} = parse_args(argv)
    if Enum.member?(parts, 1),
      do: part1(input_file)
    if Enum.member?(parts, 2),
      do: part2(input_file)
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
    |> run_inputs_p1
    |> Enum.map(&(scores_to_charlist(&1)))
    |> IO.inspect(label: "Part 1 ten-recipe score(s) are")
  end

  # part 1: each input is the number of recipes the elves will try
  # run that many and then 10 more; return the scores for the 10
  defp run_inputs_p1(inputs) do
    inputs
    |> Enum.map(fn (n_recipes) ->
      acc = {HotChocolate.Scoreboard.new([3, 7]), 0, 1}
      1..n_recipes+10
      |> Enum.reduce(acc, fn (_n, {board, elf1_i, elf2_i}) ->
        input_step({board, elf1_i, elf2_i})
      end)
      |> elem(0)
      |> HotChocolate.Scoreboard.slice(n_recipes, 10)
    end)
  end

  # see README.md for the process for each step
  defp input_step({board, elf1_i, elf2_i}) do
    board = HotChocolate.Scoreboard.create_scores(board, elf1_i, elf2_i)
    elf1_s = HotChocolate.Scoreboard.get(board, elf1_i)
    elf1_i = HotChocolate.Scoreboard.inc_index(board, elf1_i, 1 + elf1_s)
    elf2_s = HotChocolate.Scoreboard.get(board, elf2_i)
    elf2_i = HotChocolate.Scoreboard.inc_index(board, elf2_i, 1 + elf2_s)
    {board, elf1_i, elf2_i}
  end

  defp scores_to_charlist(scores) when is_list(scores) do
    Enum.map(scores, &(&1 + ?0))
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
    |> Enum.map(&(string_to_scores(&1)))
    |> run_inputs_p2
    |> IO.inspect(label: "Part 2 ten-recipe count(s) are")
  end

  defp string_to_scores(line) when is_binary(line) do
    String.to_charlist(line)
    |> Enum.map(&(&1 - ?0))
  end

  # part 2: each input is a score pattern (list of scores)
  # run until we see it; return number of recipes that preceded it
  defp run_inputs_p2(inputs) do
    inputs
    |> Enum.map(fn (score_pattern) ->
      n_scores = Enum.count(score_pattern)
      acc = {HotChocolate.Scoreboard.new([3, 7]), 0, 1}
      1..1_000_000_000
      |> Enum.reduce_while(acc, fn (_n, {board, elf1_i, elf2_i}) ->
        {board, elf1_i, elf2_i} = input_step({board, elf1_i, elf2_i})
        # tricky! since create_scores() can add 2 new scores,
        # need to check the pattern one index back as well
        latest_scores =
          HotChocolate.Scoreboard.slice(board, -n_scores, n_scores)
        latest_scores_back1 =
          HotChocolate.Scoreboard.slice(board, -n_scores-1, n_scores)
        cond do
          latest_scores_back1 == score_pattern ->
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
