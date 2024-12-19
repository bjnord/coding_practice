defmodule Onsen do
  @moduledoc """
  Documentation for `Onsen`.
  """

  import Onsen.Parser
  import History.CLI

  def possible?(towel, patterns) do
    subpossible?(towel, patterns, patterns)
  end

  def subpossible?(_towel, nil, _all_patterns), do: false
  def subpossible?([], patterns, _all_patterns) do
    Map.get(patterns, ?.) == true
  end
  def subpossible?([color | towel], patterns, all_patterns) do
    if Map.get(patterns, ?.) == true do
      if possible?([color | towel], all_patterns) do
        true
      else
        subpossible?(towel, Map.get(patterns, color), all_patterns)
      end
    else
      subpossible?(towel, Map.get(patterns, color), all_patterns)
    end
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    {towel_patterns, towels} = parse_input_file(input_path)
    towels
    |> Enum.map(&(Onsen.possible?(&1, towel_patterns)))
    |> Enum.count(&(&1))
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
