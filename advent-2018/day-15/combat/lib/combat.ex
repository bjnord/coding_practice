defmodule Combat do
  @moduledoc """
  Documentation for Combat.
  """

  import Combat.CLI
  import Combat.Arena

  @doc """
  Parse arguments and call puzzle part methods.

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

  - Part 1 answer is: ...
  """
  def part1(input_file) do
    initial_arena = parse_input(input_file)
    {{_final_grid, final_roster}, n_rounds} =
      1..1_000_000
      |> Enum.reduce_while(initial_arena, fn (round, arena) ->
        {{new_grid, new_roster}, done} = fight(arena, :puzzle)
        case done do
          true ->
            {:halt, {{new_grid, new_roster}, round}}
          false ->
            {:cont, {new_grid, new_roster}}
        end
      end)
    total_hp = final_roster
               |> Enum.map(fn ({_pos, _team, _pw, hp}) -> hp end)
               |> Enum.sum
    IO.inspect((n_rounds-1) * total_hp, label: "Part 1 combat checksum is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.reduce({0, {%{}, MapSet.new()}}, fn (line, {y, {grid, combatants}}) ->
      {y+1, parse_line({grid, combatants}, line, y)}
    end)
    |> elem(1)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    ans_type = "????"  # TODO
    parse_input(input_file)
    |> elem(0)         # TODO run the battle
    |> Enum.count()    # TODO run the battle
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> Combat.hello
      :world

  """
  def hello do
    :world
  end
end
