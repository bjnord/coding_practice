defmodule Claw do
  @moduledoc """
  Documentation for `Claw`.
  """

  import Claw.Parser
  import History.CLI

  def ab_values(%{a: {ay, ax}, b: {by, bx}, prize: {py, px}}) do
    1..100
    |> Enum.filter(fn a ->
      a * ay + div(px - a * ax, bx) * by == py
    end)
    |> Enum.map(fn a ->
      b = div(px - a * ax, bx)
      {a, b}
    end)
    |> Enum.sort()
  end

  def cost(machine) do
    machine
    |> ab_values()
    |> List.first()
    |> then(&cost_ab/1)
  end

  def cost_ab(nil), do: 0
  def cost_ab({a, b}), do: a * 3 + b

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
    |> Enum.map(&Claw.cost/1)
    |> Enum.sum()
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
