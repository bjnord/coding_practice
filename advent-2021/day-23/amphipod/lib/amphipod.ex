defmodule Amphipod do
  @moduledoc """
  Documentation for Amphipod.
  """

  alias Amphipod.Game
  alias Amphipod.Parser
  alias Submarine.CLI

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
    # "What is the least energy required to organize the amphipods?"
    game =
      File.read!(input_file)
      |> Parser.parse()
      |> Game.new()
      |> Game.play()
    #Game.render(game, false)
    game
    |> Game.total_cost()
    |> IO.inspect(label: "Part 1 answer is")
    IO.inspect(15346, label: "Part 1 WRONG answer (too high) is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
