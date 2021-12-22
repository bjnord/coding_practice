defmodule Reactor do
  @moduledoc """
  Documentation for Reactor.
  """

  alias Reactor.Cuboid, as: Cuboid
  alias Reactor.Parser, as: Parser
  alias Submarine.CLI, as: CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = CLI.parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # "Execute the reboot steps. Afterward, considering only cubes in
    # the region x=-50..50,y=-50..50,z=-50..50, how many cubes are on?"
    File.read!(input_file)
    |> Parser.parse()
    |> reboot(-50, 50)
    |> Cuboid.count_on()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Reboot the reactor, following the given `steps`.

  Returns a list of the final cuboids, all of whose cubes are `:on`.
  """
  def reboot(steps, min \\ -1_000_000, max \\ 1_000_000) do
    steps
    |> Enum.filter(fn {_on_off, cuboid} ->
      Cuboid.intersects?({{min, min, min}, {max, max, max}}, cuboid)
    end)
    |> Enum.reduce([], fn ({on_off, cur_step_cuboid}, prev_step_cuboids) ->
      shavings =
        prev_step_cuboids
        |> Enum.flat_map(fn prev_step_cuboid ->
          if Cuboid.intersects?(cur_step_cuboid, prev_step_cuboid) do
            # shave prev (this handles wholly-contained prev):
            Cuboid.shave(cur_step_cuboid, prev_step_cuboid)
          else
            # preserve prev unchanged:
            [prev_step_cuboid]
          end
        end)
      case on_off do
        :on ->
          [cur_step_cuboid | shavings]
        :off ->
          shavings
      end
    end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    # "Starting again with all cubes off, execute all reboot steps.
    # Afterward, considering all cubes, how many cubes are on?"
    File.read!(input_file)
    |> Parser.parse()
    |> reboot()
    |> Cuboid.count_on()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
