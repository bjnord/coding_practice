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
    reqs = argv
           |> input_file
           |> File.stream!
           |> Enum.map(&Sleigh.parse_requirement/1)
    {reqmap, depmap, seen} = reqs
                             |> requirements_maps
    IO.inspect(reqmap, label: "requirements")
    IO.inspect(depmap, label: "dependencies")
    IO.inspect(seen, label: "seen")
  end

  @doc """
  Map requirements list to data structures.

  ## Parameters

  - reqs: Requirements as {finish, before} tuples

  ## Returns

  Tuple:
  - 0: Map of requirements
    -- key: step which depends on another step (string)
    -- value: list of dependent steps (strings)
  - 1: Map of dependencies
    -- key: dependent step (string)
    -- value: list of steps which depend on it (strings)
  - 2: MapSet of all steps seen
  """
  def requirements_maps(reqs) do
    reqmap = Enum.reduce(reqs, %{}, fn ({finish, before}, acc) ->
      Map.update(acc, before, [finish], &([finish | &1]))
    end)
    depmap = Enum.reduce(reqs, %{}, fn ({finish, before}, acc) ->
      Map.update(acc, finish, [before], &([before | &1]))
    end)
    seen = Enum.reduce(reqs, MapSet.new(), fn ({finish, before}, acc) ->
      MapSet.put(acc, finish)
      |> MapSet.put(before)
    end)
    {reqmap, depmap, seen}
  end

  @doc """
  Create sorted list of steps with no dependencies.

  ## Parameters

  - steps: All steps (list of strings)
  - reqmap: Requirements (Map)

  ## Returns

  List of steps with no dependencies, sorted alphabetically (strings)
  """
  def no_dependencies(steps, reqmap) do
    steps
    |> Enum.reject(fn (step) -> Map.has_key?(reqmap, step) end)
    |> Enum.sort
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
