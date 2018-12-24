defmodule Lumber do
  @moduledoc """
  Documentation for Lumber.
  """

  import Lumber.CLI
  import Yard

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

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> IO.inspect(label: "Part 1 total resource value is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, _opts \\ []) do
    ans_type = "???"
    input_file
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end

  @doc """
  Print map of input file yard.
  """
  def yard_map(input_file, opts \\ []) do
    IO.puts("map of <#{input_file}>:")
    input_file
    |> parse_input(opts)
    |> Yard.map()
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Lumber.hello
      :world

  """
  def hello do
    :world
  end
end
