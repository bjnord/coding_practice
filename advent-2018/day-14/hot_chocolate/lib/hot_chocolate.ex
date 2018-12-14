defmodule HotChocolate do
  @moduledoc """
  Documentation for HotChocolate.
  """

  import HotChocolate.CLI

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
    # NB this should emit a 10-digit number (as in puzzle notes)
    |> IO.inspect(label: "Part 1 ten-recipe scores are")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    hot_chocolate = "foo"
    input_file
    |> IO.inspect(label: "Part 2 #{hot_chocolate} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> HotChocolate.hello
      :world

  """
  def hello do
    :world
  end
end
