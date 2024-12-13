defmodule Claw do
  @moduledoc """
  Documentation for `Claw`.
  """

  import Claw.Parser
  import History.CLI

  def ab_values(%{a: {ay, ax}, b: {by, bx}, prize: {py, px}}, range \\ 1..100) do
    range
    |> Enum.find(fn a ->
      a * ay + div(px - a * ax, bx) * by == py
    end)
    |> then(fn a ->
      if a do
        b = div(px - a * ax, bx)
        {a, b}
      else
        nil
      end
    end)
  end

  def cost(machine, range \\ 1..100) do
    machine
    |> ab_values(range)
    |> cost_ab()
  end

  def cost_ab(nil), do: 0
  def cost_ab({a, b}), do: a * 3 + b

  def higher(%{a: {ay, ax}, b: {by, bx}, prize: {py, px}}) do
    %{a: {ay, ax}, b: {by, bx}, prize: {py + 10_000_000_000_000, px + 10_000_000_000_000}}
  end

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
