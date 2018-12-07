defmodule Sleigh do
  @moduledoc """
  Documentation for Sleigh.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(argv) do
    _reqs = argv
            |> input_file
            |> File.stream!
            |> Enum.map(&Sleigh.parse_requirement/1)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(argv) do
    _reqs = argv
            |> input_file
            |> File.stream!
            |> Enum.map(&Sleigh.parse_requirement/1)
  end

  @doc """
  Get name of input file from command-line arguments.

  ## Parameters

  - argv: Command-line arguments

  ## Returns

  Input filename (or aborts if argv invalid)
  """
  def input_file(argv) do
    case argv do
      [filename] -> filename
      _          -> abort('Usage: sleigh filename', 64)
    end
  end

  @doc """
  Parse requirement from string.

  ## Parameters

  - requirement of the form "Step C must be finished before step A can begin."

  ## Returns

  Requirement as {finish, before} tuple
  """
  def parse_requirement(str) do
    r = Regex.named_captures(~r/Step\s+(?<finish>\w)\s+must\s+be\s+finished\s+before\s+step\s+(?<before>\w)\s+can\s+begin\./, str)
    {r["finish"], r["before"]}
  end
end
