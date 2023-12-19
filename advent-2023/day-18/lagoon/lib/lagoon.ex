defmodule Lagoon do
  @moduledoc """
  Documentation for `Lagoon`.
  """

  import Lagoon.Parser
  import Snow.CLI

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
    parse_input(input_file, part: 1)
    |> lagoon_size()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file, part: 2)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Find lagoon size from a list of dig instructions.

  This combines two algorithms:
  1. the [Shoelace formula](https://en.wikipedia.org/wiki/Shoelace_formula) - area of a simple polygon
  2. [Pick's theorem](https://en.wikipedia.org/wiki/Pick%27s_theorem) - interior and boundary points of a simple polygon

  See [this Reddit comment thread](https://www.reddit.com/r/adventofcode/comments/18l2tap/2023_day_18_the_elves_and_the_shoemaker/kdv5bzi/) for an explanation of how/why these are combined.

  ## Parameters

  - `instructions`: the list of dig instructions

  Returns the lagoon size (integer).
  """
  def lagoon_size(instructions) do
    instructions
    |> Enum.reduce({{0, 0}, 0}, fn {dir, dist, _}, {{y1, x1}, area_x2} ->
      {dy, dx} = dir_offset(dir)
      {y2, x2} = {y1 + dy * dist, x1 + dx * dist}
      shoelace_x2 = (x1 * y2) - (x2 * y1)
      picks_border_x2 = dist
      {{y2, x2}, area_x2 + shoelace_x2 + picks_border_x2}
    end)
    |> then(fn {_pos, area_x2} -> div(area_x2, 2) + 1 end)
  end

  defp dir_offset(:up), do: {-1, 0}
  defp dir_offset(:down), do: {1, 0}
  defp dir_offset(:left), do: {0, -1}
  defp dir_offset(:right), do: {0, 1}
end
