defmodule Reservoir do
  @moduledoc """
  Documentation for Reservoir.
  """

  import Reservoir.CLI
  import Reservoir.Flow

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, parts} = parse_args(argv)
    if Enum.member?(parts, 1),
      do: part1(input_file)
    if Enum.member?(parts, 2),
      do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: 38451
  """
  def part1(input_file) do
    input_file
    |> parse_input()
    |> flow()
    |> water_count([:flow, :water])
    |> IO.inspect(label: "Part 1 squares reached by water is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_clay_input()
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: 28142
  """
  def part2(input_file) do
    input_file
    |> parse_input()
    |> flow()
    |> water_count([:water])
    |> IO.inspect(label: "Part 2 squares containing water is")
  end
end
