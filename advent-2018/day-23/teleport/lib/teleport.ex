defmodule Teleport do
  @moduledoc """
  Documentation for Teleport.
  """

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
  def part2(input_file, _opts \\ []) do
    ans_type = "???"
    input_file
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end

  @doc """
  Compute the Manhattan distance between two 3-D points.

  "Take the sum of the absolute values of the differences of the coordinates.
  For example, if x=(a,b) and y=(c,d), the Manhattan distance between x and y is |a−c|+|b−d|."
  <https://math.stackexchange.com/a/139604>

  ## Example

  iex> Teleport.manhattan({1, 2, 3}, {2, 3, 4})
  3

  """
  def manhattan({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end
