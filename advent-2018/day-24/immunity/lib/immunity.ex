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
    {_new_army1, _new_army2, targets, candidates_list, skirmishes} =
      fight(army1, army2)
    if opts[:verbose] do
      Immunity.Narrative.for_fight(army1, army2, targets, candidates_list, skirmishes)
      |> Enum.each(fn (line) -> IO.puts(line) end)
    end
    "?"
    |> IO.inspect(label: "Part 1 winning army units is")
  end

  defp parse_input_file(input_file, opts) do
    input_file
    |> File.read!
    |> parse_input_content(opts)
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
