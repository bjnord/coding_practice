defmodule Geology do
  @moduledoc """
  Documentation for Geology.
  """

  import Cave
  import Geology.CLI

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

  - Part 1 answer is: 10395
  """
  def part1(input_file, _opts \\ []) do
    cave =
      input_file
      |> parse_input()
    fast_cave = cache_erosion(cave)
    risk_level(fast_cave, target_range(fast_cave))
    |> IO.inspect(label: "Part 1 total risk level is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - INCORRECT Part 2 answer is: 1052 (too high)
  - Part 2 answer is: ...
  """
  def part2(input_file, _opts \\ []) do
    cave =
      input_file
      |> parse_input()
    fast_cave = cache_erosion(cave)
    cheapest_path(fast_cave, {0, 0}, :torch, fast_cave.target)
    |> IO.inspect(label: "Part 2 fewest minutes to target is")
  end

  @doc """
  Print map of input file cave.
  """
  def cave_map(input_file, _opts \\ []) do
    IO.puts("map of <#{input_file}>:")
    cave =
      input_file
      |> parse_input()
    fast_cave = cache_erosion(cave)
    map(fast_cave, target_range(fast_cave))
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Geology.hello
      :world

  """
  def hello do
    :world
  end
end
