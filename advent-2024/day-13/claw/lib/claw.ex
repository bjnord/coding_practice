defmodule Claw do
  @moduledoc """
  Documentation for `Claw`.
  """

  import Claw.Parser
  import History.CLI

  def ab_values(%{a: {ay, ax}, b: {by, bx}, prize: {py, px}}) do
    left = Nx.tensor([[ax, bx], [ay, by]], type: :f64)
    right = Nx.tensor([px, py], type: :f64)
    dot = Nx.LinAlg.solve(left, right)
    a = Nx.to_number(dot[0])
        |> round()
    b = Nx.to_number(dot[1])
        |> round()
    solution(a, b, ay, ax, by, bx, py, px)
  end

  defp solution(a, b, ay, ax, by, bx, py, px) when
    a * ay + b * by == py and
    a * ax + b * bx == px, do: {a, b}
  defp solution(_a, _b, _ay, _ax, _by, _bx, _py, _px), do: nil

  def cost(machine) do
    machine
    |> ab_values()
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
    |> Enum.map(&Claw.higher/1)
    |> Enum.map(&Claw.cost/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
