defmodule Immunity do
  @moduledoc """
  Documentation for Immunity.
  """

  import Immunity.CLI
  import Immunity.Combat
  import Immunity.InputParser

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(input_file, opts \\ []) do
    [army1, army2] =
      input_file
      |> parse_input_file(opts)
    this_means_war(army1, army2, opts)
    |> IO.inspect(label: "Part 1 winning army units is")
  end

  defp parse_input_file(input_file, opts) do
    input_file
    |> File.read!
    |> parse_input_content(opts)
  end

  defp this_means_war(army1, army2, opts) do
    Stream.cycle([true])
    |> Enum.reduce_while({army1, army2}, fn (_t, {army1, army2}) ->
      {new_army1, new_army2, candidates_list, skirmishes} =
        fight(army1, army2)
      if opts[:verbose] do
        Immunity.Narrative.for_fight(army1, army2, candidates_list, skirmishes)
        |> Enum.each(fn (line) -> IO.puts(line) end)
      end
      victor = victor(new_army1, new_army2)
      if victor do
        {:halt, Immunity.Group.total_units(victor)}
      else
        {:cont, {new_army1, new_army2}}
      end
    end)
  end

  # "After the fight is over, if both armies still contain units, a new
  # fight begins; combat only ends once one army has lost all of its units."
  defp victor(army1, army2) do
    cond do
      Enum.empty?(army1) -> army2
      Enum.empty?(army2) -> army1
      true -> nil
    end
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, _opts \\ []) do
    ans_type = "???"
    input_file
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end
end
