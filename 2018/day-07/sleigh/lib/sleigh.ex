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
    {reqmap, depmap, steps} = reqs
                              |> requirements_maps
    no_dependencies(steps, reqmap)
    |> execute_steps([], reqmap, depmap)
    |> Enum.reverse
    |> List.to_string
    |> IO.inspect(label: "Part 1 step order is")
  end

  defp execute_steps([step | remaining_steps], acc_steps, reqmap, depmap) do
    remaining_steps =
      freed_by(step, acc_steps, reqmap, depmap) ++ remaining_steps
      |> Enum.sort
    execute_steps(remaining_steps, [step | acc_steps], reqmap, depmap)
  end

  defp execute_steps([], acc_steps, _reqmap, _depmap) do
    acc_steps
  end

  @doc """
  Return list of steps freed of dependencies by an executed step.

  ## Parameters

  - step: The step being executed (string)
  - done_steps: The steps already executed (list of strings)
  - reqmap: The step requirements (map)
  - depmap: The step dependencies (map)

  ## Returns

  Steps newly freed of dependencies (list of strings)
  """
  # OPTIMIZE done_steps should be MapSet
  def freed_by(step, done_steps, reqmap, depmap) do
    case depmap[step] do
      nil ->
        []
      _ ->
        depmap[step]
        |> Enum.reduce([], fn (dstep, acc) ->
          left = reqmap[dstep]
                 |> Enum.reject(fn (rstep) ->
                   (step == rstep) || Enum.member?(done_steps, rstep)
                 end)
          case left do
          [] -> [dstep | acc]
          _  -> acc
          end
        end)
    end
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
