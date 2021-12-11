defmodule Octopus do
  @moduledoc """
  Documentation for Octopus.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Octopus.hello()
      :world

  """
  def hello do
    :world
  end

  import Octopus.Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    grid =
      input_file
      |> parse_input(opts)
      |> Octopus.Grid.new()
    grid =
      1..100
      |> Enum.reduce(grid, fn (_n, grid) ->
        Octopus.Grid.increase_energy(grid)
      end)
    grid.flashes
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> IO.inspect(label: "Part 2 answer is")
  end
end
