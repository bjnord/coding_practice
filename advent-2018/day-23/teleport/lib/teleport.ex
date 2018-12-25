defmodule Teleport do
  @moduledoc """
  Documentation for Teleport.
  """

  import Nanobot
  import Teleport.CLI

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

  - Part 1 answer is: 613
  """
  def part1(input_file, opts \\ []) do
    bots =
      input_file
      |> parse_input(opts)
    {max_bot_pos, max_bot_r} =
      bots
      |> Enum.max_by(fn ({_pos, r}) -> r end)
    bots_in_range =
      bots
      |> Enum.filter(fn ({pos, _r}) ->
        manhattan(max_bot_pos, pos) <= max_bot_r
      end)
      |> Enum.count
    IO.inspect(bots_in_range, label: "Part 1 nanobots in range is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, opts \\ []) do
    bots =
      input_file
      |> parse_input(opts)
    {count, intersection_ranges} =
      bots
      |> Enum.map(fn (compare_bot) -> intersection_ranges_of(bots, compare_bot) end)
      |> Enum.max_by(fn ({n, _ints}) -> n end)
    IO.inspect(count, label: "maximum intersection count")
    _ranges = reduced_ranges(intersection_ranges)
             |> IO.inspect(label: "reduced intersection")
    "?"
    |> IO.inspect(label: "Part 2 distance to closest point is")
  end
end
