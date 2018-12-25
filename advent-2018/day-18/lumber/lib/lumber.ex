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

  - Part 1 answer is: 603098
  """
  def part1(input_file, opts \\ []) do
    counts =
      input_file
      |> parse_input(opts)
      |> strange_magic(10)
      |> count()
    (counts[:trees] * counts[:lumber])
    |> IO.inspect(label: "Part 1 total resource value is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: 210000
  """
  def part2(input_file, opts \\ []) do
    {yard, minute, halt_cksum, states} =
      input_file
      |> parse_input(opts)
      |> strange_magic_until_repeat()
    if opts[:verbose] do
      Yard.map(yard, label_minute: minute)
      |> Enum.map(fn (line) -> IO.puts(line) end)
    end
    counts =
      extrapolate_state(states, minute, halt_cksum, 1_000_000_000)
    (counts[:trees] * counts[:lumber])
    |> IO.inspect(label: "Part 2 total resource value is")
  end

  @doc """
  Print map of input file yard.
  """
  def yard_map(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> Yard.map(label: "map of <#{input_file}>:")
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end
end
