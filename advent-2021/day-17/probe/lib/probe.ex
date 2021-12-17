defmodule Probe do
  @moduledoc """
  Documentation for Probe.
  """
  import Submarine.CLI

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
    # "Find the initial velocity that causes the probe to reach the highest
    # y position and still eventually be within the target area after any
    # step. What is the highest y position it reaches on this trajectory?"
    File.read!(input_file)
    |> Probe.Parser.parse()
    |> Probe.max_height()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Return the max height that can be achieved by firing the probe toward the
  target area `{{min_x, max_x}, {min_y, max_y}}` (by trying all plausible
  firing velocity vectors).
  """
  def max_height({{min_x, max_x}, {min_y, max_y}}) do
    for xv <- 1..max_x, yv <- 1..max_x do
      fire({xv, yv}, {{min_x, max_x}, {min_y, max_y}})
    end
    |> Enum.filter(fn {hit_miss, _positions} -> hit_miss == :hit end)
    |> Enum.map(fn {_hit_miss, positions} -> max_height_of_positions(positions) end)
    |> Enum.max()
  end

  defp max_height_of_positions(positions) do
    positions
    |> Enum.map(fn {_x, y} -> y end)
    |> Enum.max()
  end

  @doc """
  Fire a probe at the velocity `{xv, yv}` toward the target area
  `{{min_x, max_x}, {min_y, max_y}}`. Returns indicator of whether
  the probe hit the target area, and a list of positions visited.
  """
  def fire({xv, yv}, {{min_x, max_x}, {min_y, max_y}}) do
    Stream.cycle([true])
    |> Enum.reduce_while({{0, 0}, {xv, yv}, []}, fn (_, {{x, y}, {xv, yv}, positions}) ->
      {x, y} = move({x, y}, {xv, yv})
      {xv, yv} = slow({xv, yv})
      case within({x, y}, {{min_x, max_x}, {min_y, max_y}}) do
        :moving -> {:cont, {{x, y}, {xv, yv}, [{x, y} | positions]}}
        hit_miss -> {:halt, {hit_miss, Enum.reverse([{x, y} | positions])}}
      end
    end)
  end

  defp move({x, y}, {xv, yv}), do: {x + xv, y + yv}

  defp slow({xv, yv}) do
    xv = cond do
      xv > 0 -> xv - 1
      xv < 0 -> xv + 1
      xv == 0 -> xv
    end
    {xv, yv - 1}
  end

  defp within({x, y}, {{min_x, max_x}, {min_y, max_y}}) do
    cond do
      between(x, min_x, max_x) && between(y, min_y, max_y) -> :hit
      y < min_y -> :miss
      true -> :moving
    end
  end

  defp between(n, min_n, max_n) do
    n >= min_n && n <= max_n
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Probe.Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
