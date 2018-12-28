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

  - Part 1 answer is: 26937
  """
  def part1(input_file, opts \\ []) do
    [army1, army2] =
      input_file
      |> parse_input_file(opts)
    this_means_war(army1, army2, opts)
    |> Immunity.Group.total_units()
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
        {:halt, victor}
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

  - Part 2 INCORRECT answer is: 106 (too low)
  - Part 2 answer is: ...
  """
  def part2(input_file, opts \\ []) do
    [army1, army2] =
      input_file
      |> parse_input_file(opts)
    {boost, units} =
      Stream.cycle([true])
      |> Enum.reduce_while(1..100_000, fn (_t, min_boost..max_boost) ->
        try_boost = min_boost + div(max_boost - min_boost, 2)
        IO.inspect({min_boost..max_boost, try_boost}, label: "trying boost")
        units = boosted_war(army1, army2, try_boost, opts)
        cond do
          min_boost > 100_000 ->
            raise "boom"
          units && (min_boost == max_boost) ->
            {:halt, {min_boost, units}}
          min_boost == max_boost-1 ->
            #IO.inspect({min_boost+1..max_boost}, label: "no units, raising lower fence")
            {:cont, min_boost+1..max_boost}
          min_boost == max_boost ->
            #IO.inspect({min_boost+1..max_boost+1}, label: "no units, raising both fences")
            {:cont, min_boost+1..max_boost+1}
          units ->
            #IO.inspect({min_boost..try_boost}, label: "units=#{units}, taking lower half")
            {:cont, min_boost..try_boost}
          true ->
            #IO.inspect({try_boost..max_boost}, label: "no units, taking upper half")
            {:cont, try_boost..max_boost}
        end
      end)
    units
    |> IO.inspect(label: "Part 2 Immune System units (with boost=#{boost}) is")
  end

  defp boosted_war(army1, army2, boost, opts) do
    boosted_army1 =
      army1
      |> Enum.map(fn (group) -> Immunity.Group.clone(group, :attack, group.attack + boost) end)
    victor = this_means_war(boosted_army1, army2, opts)
    victor_name = List.first(victor)
                  |> Immunity.Group.army_name()
    if victor_name == "Immune System" do
      Immunity.Group.total_units(victor)
    else
      nil
    end
  end
end
