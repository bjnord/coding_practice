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

  - Part 1 answer is: "EPWCFXKISTZVJHDGNABLQYMORU"
  """
  def part1(argv) do
    reqs = argv
           |> input_file
           |> File.stream!
           |> Enum.map(&Sleigh.parse_requirement/1)
    {steps, reqmap, depmap} = reqs
                              |> requirements_maps
    no_dependencies(steps, reqmap)
    |> execute_steps({[], MapSet.new()}, reqmap, depmap)
    |> Kernel.elem(0)
    |> Enum.reverse
    |> List.to_string
    |> IO.inspect(label: "Part 1 step order is")
  end

  # we need to keep done steps as both
  # - list, so we know the order of step execution
  # - set, for efficiency in checking if a step is already done
  defp execute_steps([step | remaining_steps], {done_list, done_set}, reqmap, depmap) do
    remaining_steps =
      freed_by(step, done_set, reqmap, depmap) ++ remaining_steps
      |> Enum.sort
    acc = {[step | done_list], MapSet.put(done_set, step)}
    execute_steps(remaining_steps, acc, reqmap, depmap)
  end

  defp execute_steps([], acc, _reqmap, _depmap) do
    acc
  end

  @doc """
  Return list of steps freed of dependencies by an executed step.

  ## Parameters

  - step: The step being executed (string)
  - done_set: The steps already executed (mapset of strings)
  - reqmap: The step requirements (map)
  - depmap: The step dependencies (map)

  ## Returns

  Steps newly freed of dependencies (list of strings)
  """
  def freed_by(step, done_set, reqmap, depmap) do
    case depmap[step] do
      nil ->
        []
      _ ->
        depmap[step]
        |> Enum.reduce([], fn (dstep, acc) ->
          left = reqmap[dstep]
                 |> Enum.reject(fn (rstep) ->
                   (step == rstep) || MapSet.member?(done_set, rstep)
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
  - 0: MapSet of all steps seen
  - 1: Map of requirements
    -- key: step which depends on another step (string)
    -- value: list of dependent steps (strings)
  - 2: Map of dependencies
    -- key: dependent step (string)
    -- value: list of steps which depend on it (strings)
  """
  def requirements_maps(reqs) do
    seen = Enum.reduce(reqs, MapSet.new(), fn ({finish, before}, acc) ->
      MapSet.put(acc, finish)
      |> MapSet.put(before)
    end)
    reqmap = Enum.reduce(reqs, %{}, fn ({finish, before}, acc) ->
      Map.update(acc, before, [finish], &([finish | &1]))
    end)
    depmap = Enum.reduce(reqs, %{}, fn ({finish, before}, acc) ->
      Map.update(acc, finish, [before], &([before | &1]))
    end)
    {seen, reqmap, depmap}
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
