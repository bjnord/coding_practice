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

  - Part 1 answer is: 250594
  """
  def part1(input_file) do
    initial_arena = parse_input(input_file)
    debug_inspect_arena(initial_arena, :debug_top, 0)
    {final_arena, round} = battle(initial_arena, :puzzle, true)
    debug_inspect_arena(final_arena, :debug_top, round)
    dump_outcome(final_arena, round, 1)
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_puzzle()
  end

  defp dump_outcome(arena, round, part) do
    IO.puts("Part #{part}:")
    IO.puts("Combat ends after #{round-1} full rounds")
    total_hp = total_hp(arena)
    victors = victors(arena)
    IO.puts("#{victors} win with #{total_hp} total hit points left")
    checksum = (round-1) * total_hp
    IO.puts("Outcome: #{round-1} * #{total_hp} = #{checksum}")
    IO.puts("")
  end

  defp victors({_grid, roster}) do
    roster
    |> Enum.take(1)
    |> List.first
    |> elem(1)
    |> case do
      :elf -> 'Elves'
      :goblin -> 'Goblins'
    end
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
