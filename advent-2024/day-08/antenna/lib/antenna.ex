defmodule Antenna do
  @moduledoc """
  Documentation for `Antenna`.
  """

  import Antenna.Parser
  import History.CLI

  def groups({antennas, _dim}) do
    antennas
    |> Enum.reduce(%{}, fn {pos, which}, acc ->
      Map.update(acc, which, [pos], &([pos | &1]))
    end)
  end

  def antinodes({antennas, {dim_y, dim_x} = dim}) do
    groups({antennas, dim})
    |> Enum.map(fn {_ch, positions} ->
      History.Math.pairings(positions)
      |> Enum.map(fn {{ay, ax}, {by, bx}} ->
        [
          {ay + (by - ay) * 2, ax + (bx - ax) * 2},
          {by + (ay - by) * 2, bx + (ax - bx) * 2},
        ]
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reject(fn {y, x} ->
      out_of_bounds?(y, dim_y) || out_of_bounds?(x, dim_x)
    end)
  end

  defp out_of_bounds?(n, _max) when (n < 0), do: true
  defp out_of_bounds?(n, max) when (n >= max), do: true
  defp out_of_bounds?(_n, _max), do: false

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Antenna.antinodes()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
