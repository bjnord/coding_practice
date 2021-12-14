defmodule Polymer do
  @moduledoc """
  Documentation for Polymer.
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
    # "Apply 10 steps of pair insertion to the polymer template and find
    # the most and least common elements in the result. What do you get
    # if you take the quantity of the most common element and subtract the
    # quantity of the least common element?"
    {min, max} =
      File.read!(input_file)
      |> Polymer.Stepper.new()
      |> Polymer.Stepper.step(10)
      |> Polymer.Stepper.min_max()
    (max - min)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    # "Apply 40 steps of pair insertion to the polymer template and find
    # the most and least common elements in the result. What do you get
    # if you take the quantity of the most common element and subtract the
    # quantity of the least common element?"
    {min, max} =
      File.read!(input_file)
      |> Polymer.Stepper.new()
      |> Polymer.Stepper.step(40)
      |> Polymer.Stepper.min_max()
    (max - min)
    |> IO.inspect(label: "Part 2 answer is")
  end
end
