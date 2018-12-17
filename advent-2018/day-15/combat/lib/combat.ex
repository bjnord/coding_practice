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

  - Part 1 INCORRECT answer (too high) is: 266216
  """
  def part1(input_file) do
    initial_arena = parse_input(input_file)
    debug_inspect_arena(initial_arena, :debug_top, 0)
    {final_arena, n_rounds} = battle(initial_arena, :puzzle, true)
    total_hp = total_hp(final_arena)
    debug_inspect_arena(final_arena, :debug_top, n_rounds)
    debug_inspect(n_rounds-1, :debug_top, label: "Complete Rounds")
    debug_inspect(total_hp, :debug_top, label: "Total HP")
    IO.inspect((n_rounds-1) * total_hp, label: "Part 1 combat checksum is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_puzzle()
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
