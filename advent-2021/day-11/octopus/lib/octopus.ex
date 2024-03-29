defmodule Octopus do
  @moduledoc """
  Documentation for Octopus.
  """

  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    grid =
      File.read!(input_file)
      |> Octopus.Grid.new()
    # "Given the starting energy levels of the dumbo octopuses in your
    # cavern, simulate 100 steps. How many total flashes are there after
    # 100 steps?"
    1..100
    |> Enum.reduce(grid, fn (_n, grid) ->
      Octopus.Grid.increase_energy(grid)
    end)
    |> Octopus.Grid.n_flashes()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    grid =
      File.read!(input_file)
      |> Octopus.Grid.new()
    # "If you can calculate the exact moments when the octopuses will
    # all flash simultaneously, you should be able to navigate through the
    # cavern. What is the first step during which all octopuses flash?"
    1..1_000_000
    |> Enum.reduce_while(grid, fn (n, grid) ->
      Octopus.Grid.increase_energy(grid)
      |> halt_if_synchronized(n)
    end)
    |> IO.inspect(label: "Part 2 answer is")
  end
  defp halt_if_synchronized(grid, n) do
    if Octopus.Grid.synchronized?(grid), do: {:halt, n}, else: {:cont, grid}
  end
end
