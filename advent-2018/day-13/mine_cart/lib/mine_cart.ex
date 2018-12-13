defmodule MineCart do
  @moduledoc """
  Documentation for MineCart.
  """

  import MineCart.CLI

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    input_file = parse_args(argv)
    part1(input_file)
    part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(input_file) do
    input_file
    |> IO.inspect(label: "Part 1 first crash location is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    input_file
    |> IO.inspect(label: "Part 2 #{false} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> MineCart.hello
      :world

  """
  def hello do
    :world
  end
end
