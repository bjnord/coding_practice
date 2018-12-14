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
    |> run_trials
    |> IO.inspect(label: "Part 1 ten-recipe score(s) are")
  end

  defp run_trials(trials) do
    trials
    |> Enum.map(fn (n_recipes) ->
      acc = {HotChocolate.Scoreboard.new([3, 7]), 0, 1}
      1..n_recipes+10
      |> Enum.reduce(acc, fn (_n, {board, elf1_i, elf2_i}) ->
        board = HotChocolate.Scoreboard.create(board, elf1_i, elf2_i)
        elf1_s = HotChocolate.Scoreboard.get(board, elf1_i)
        elf1_i = HotChocolate.Scoreboard.inc_index(board, elf1_i, 1 + elf1_s)
        elf2_s = HotChocolate.Scoreboard.get(board, elf2_i)
        elf2_i = HotChocolate.Scoreboard.inc_index(board, elf2_i, 1 + elf2_s)
        {board, elf1_i, elf2_i}
      end)
      |> elem(0)
      |> HotChocolate.Scoreboard.slice(n_recipes, 10)
      |> Enum.map(fn (score) -> score + ?0 end)
    end)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    hot_chocolate = "foo"
    input_file
    |> IO.inspect(label: "Part 2 #{hot_chocolate} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> HotChocolate.hello
      :world

  """
  def hello do
    :world
  end
end
