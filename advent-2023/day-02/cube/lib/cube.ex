defmodule Cube do
  @moduledoc """
  Documentation for `Cube`.
  """

  import Cube.Parser
  alias Cube.Game, as: Game
  import Snow.CLI

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
    parse_input(input_file)
    |> Stream.map(&Game.max/1)
    |> Stream.filter(&Game.possible?/1)
    |> Stream.map(fn game -> game.id end)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    |> Stream.map(&Game.max/1)
    |> Stream.map(&Game.cube_power/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
