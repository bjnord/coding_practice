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
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Find lagoon border size from a list of dig instructions.

  ## Parameters

  - `instructions`: the list of dig instructions

  Returns the lagoon border size (integer).
  """
  def border_size(instructions) do
    instructions
    |> dig()
    |> Map.keys()
    |> Enum.count()
  end

  defp dig(instructions) do
    initial_map_pos =
      {
        %{{0, 0} => ?#},
        {0, 0},
      }
    instructions
    |> Enum.reduce(initial_map_pos, fn {dir, dist, _}, {map, {y, x}} ->
      {dy, dx} = dir_offset(dir)
      1..dist
      |> Enum.reduce({map, {y, x}}, fn _, {map, {y, x}} ->
        {
          Map.put(map, {y + dy, x + dx}, ?#),
          {y + dy, x + dx}
        }
      end)
    end)
    |> elem(0)
  end

  defp dir_offset(:up), do: {-1, 0}
  defp dir_offset(:down), do: {1, 0}
  defp dir_offset(:left), do: {0, -1}
  defp dir_offset(:right), do: {0, 1}
end
