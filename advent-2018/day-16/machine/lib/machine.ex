defmodule Machine do
  @moduledoc """
  Documentation for Machine.
  """

  import Machine.CLI

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

  - Part 1 answer is: ...
  """
  def part1(input_file) do
    input_file
    |> IO.inspect(label: "Part 1 sample count is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    arg_type = "?"
    input_file
    |> IO.inspect(label: "Part 2 #{arg_type} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> Machine.hello
      :world

  """
  def hello do
    :world
  end
end
