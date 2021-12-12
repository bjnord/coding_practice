defmodule Cave do
  @moduledoc """
  Documentation for Cave.
  """

  import Cave.Graph
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # "How many paths through this cave system are there that visit small
    # caves at most once?"
    File.read!(input_file)
    |> parse_input_string()
    |> paths()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts) do
    ptfunc =
      if opts[:times] do
        &timed_paths_twice/1
      else
        &paths_twice/1
      end
    # "[Y]ou realize you might have time to visit a single small cave
    # twice. Given these new rules, how many paths through this cave
    # system are there?"
    File.read!(input_file)
    |> parse_input_string()
    |> ptfunc.()
    |> Enum.count()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
