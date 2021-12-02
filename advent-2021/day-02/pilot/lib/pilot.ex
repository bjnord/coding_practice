defmodule Pilot do
  @moduledoc """
  Documentation for Pilot.
  """

  import Pilot.CLI

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
  """
  def part1(input_file, opts \\ []) do
    {x, y} = input_file
             |> parse_input(opts)
             |> Enum.reduce({0, 0}, fn ({dx, dy}, {x, y}) ->
               {dx + x, dy + y}
             end)
    IO.inspect(x * y, label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    IO.inspect(true, label: "Part 2 answer is")
  end
end
