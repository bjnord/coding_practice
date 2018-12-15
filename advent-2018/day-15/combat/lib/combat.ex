defmodule Combat do
  @moduledoc """
  Documentation for Combat.
  """

  import Combat.CLI

  @doc """
  Parse arguments and call puzzle part methods.

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
    |> IO.inspect(label: "Part 1 combat checksum is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    combat = "foo"
    input_file
    |> IO.inspect(label: "Part 2 #{combat} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> Combat.hello
      :world

  """
  def hello do
    :world
  end
end
